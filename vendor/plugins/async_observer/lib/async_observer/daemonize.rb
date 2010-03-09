# async-observer - Rails plugin for asynchronous job execution
# Copyright (C) 2009 Todd A. Fisher.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
module AsyncObserver; end

class AsyncObserver::Daemonize
  def self.detach(pidfile='log/worker.pid',&block)
    # daemonize, create a pipe to send status to the parent process, after the child has successfully started or failed
    fork do
      Process.setsid
      fork do
        Process.setsid
        File.open(pidfile, 'wb') {|f| f << Process.pid}
        at_exit { File.unlink(pidfile) }
        File.umask 0000
        STDIN.reopen "/dev/null"
        STDOUT.reopen "/dev/null", "a"
        STDERR.reopen STDOUT
        block.call
      end
    end
  end
end
