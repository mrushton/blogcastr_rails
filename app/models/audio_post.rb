class AudioPost < Post 
  #MVR - store in either s3 or locally on file
  if Rails.env.production?
    #TODO: post processing needs to be tested in production environment
    has_attached_file :audio, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :path => "audio/:id/:style/:basename.:style"
  else
    has_attached_file :audio, :url => "/system/audio/:id/:style/:basename.:style_extension"
  end
  #MVR - paperclip validations need to come after has_attached_file
  validates_attachment_content_type :audio, :content_type => ["audio/mpeg"], :message => "must be a mp3"
  validates_attachment_size :audio, :less_than => 10.megabytes, :message => "file size must be less than 10MB"
  #MVR - encode audio asynchronously
  after_create do |audio_post|
    #MVR - save the attached files since they get saved after_save
    audio_post.save_attached_files
    #MVR - fork processes and then wait for completion
    #TODO: performance issues, we are running in a full rails environment which I'm not terribly thrilled about?
    ogg_pid = fork
    if ogg_pid.nil?
      FileUtils.mkdir_p(File.split(audio_post.audio.path(:ogg))[0])
      exec("#{audio_post.audio.path(:ogg)}  ffmpeg -i \"#{audio_post.audio_post_process_file_name}\" -acodec vorbis #{audio_post.audio.path(:ogg)}")
    end
    #MVR - if an mp3 was uploaded just copy it
    if (audio_post.audio_content_type != "audio/mpeg")
      mp3_pid = fork
      if mp3_pid.nil?
        FileUtils.mkdir_p(File.split(audio_post.audio.path(:mp3))[0])
        exec("ffmpeg -i \"#{audio_post.audio_post_process_file_name}\" -acodec vorbis #{audio_post.audio.path(:mp3)}")
      end
    else
      if Rails.env.production?

      else
        FileUtils.mkdir_p(File.split(audio_post.audio.path(:mp3))[0])
        FileUtils.cp(audio_post.audio.path(:original), audio_post.audio.path(:mp3))
      end
    end
    #MVR - wait for children to finish
    Process.waitall
   # ogg_err = wait ogg_pid
   # if (audio_post.audio_content_type != "audio/mpeg")
   #   mp3_err = wait mp3_pid
   # end
    #MVR - remove post processing file
    FileUtils.rm_f(audio_post.audio_post_process_file_name)
    #MVR - check for errors
   # if (ogg_err != 0 || mp3_err != 0)
      #MVR - update database    
   #   audio_post.update_attributes(:audio => nil, :audio_post_process_file_name => nil)
      #MVR - update blogcast 
   #   return
   # end
    #MVR - store in s3 or locally on file 
    if Rails.env.production?

    else

    end
    #MVR - update database    
    audio_post.update_attribute(:audio_post_process_file_name, nil)
    #MVR - update blogcast 
  end
end
