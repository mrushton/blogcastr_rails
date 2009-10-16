

# windows compatibility, need different library name
if(PLATFORM =~ /mingw|mswin/) then
  $libname = '/ms/libpq'
else
  $libname = 'pq'
end

if(PLATFORM =~ /darwin/) then
	# test if postgresql is probably universal
	bindir = (IO.popen("pg_config --bindir").readline.chomp rescue nil)
	filetype = (IO.popen("file #{bindir}/pg_config").
			readline.chomp rescue nil)
	# if it's not universal, ARCHFLAGS should be set
	if((filetype !~ /universal binary/) && ENV['ARCHFLAGS'].nil?) then
		arch = (IO.popen("uname -m").readline.chomp rescue nil)
		$stderr.write %{
		===========   WARNING   ===========

		You are building this extension on OS X without setting the
		ARCHFLAGS environment variable, and PostgreSQL does not appear
		to have been built as a universal binary. If you are seeing this
		message, that means that the build will probably fail.

		Try setting the environment variable ARCHFLAGS
		to '-arch #{arch}' before building.

		For example:
		(in bash) $ export ARCHFLAGS='-arch #{arch}'
		(in tcsh) $ setenv ARCHFLAGS '-arch #{arch}'

		Then try building again.

		===================================
		}
		# We don't exit here. Who knows? It might build.
	end
end

if RUBY_VERSION < '1.8'
  puts 'This library is for ruby-1.8 or higher.'
  exit 1
end

require 'mkmf'

def config_value(type)
  ENV["POSTGRES_#{type.upcase}"] || pg_config(type)
end

def pg_config(type)
  IO.popen("pg_config --#{type}dir").readline.chomp rescue nil
end

def have_build_env
  have_library($libname) && have_header('libpq-fe.h') && have_header('libpq/libpq-fs.h')
end

dir_config('pgsql', config_value('include'), config_value('lib'))

required_libraries = []
desired_functions = %w(PQsetClientEncoding pg_encoding_to_char PQfreemem PQserverVersion)
compat_functions = %w(PQescapeString PQexecParams)

if have_build_env
  required_libraries.each(&method(:have_library))
  desired_functions.each(&method(:have_func))
  $objs = ['postgres.o','libpq-compat.o'] if compat_functions.all?(&method(:have_func))
  create_makefile("postgres")
else
  puts 'Could not find PostgreSQL build environment (libraries & headers): Makefile not created'
end
