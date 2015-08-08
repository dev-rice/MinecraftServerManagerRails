class MinecraftWorld
    attr_reader :name, :directory, :version

    def initialize(args)
        @name = args[:name]
        @directory = args[:directory]
        @version = args[:version]
    end

    def start(server)
        enter_world_dir
        server.start(version)
    end

    def enter_world_dir
        Dir.chdir(directory)
    end

end

class MinecraftServer
    attr_reader :pid, :running, :pid_filepath

    def start_world(world)
        world.start(self)
    end

    def start(version)
        filename = get_server_filename(version)
        run_sever_command(filename)

    end

    def run_sever_command(filename)
        @pid = fork do
          # this code is run in the child process
          # you can do anything here, like changing current directory or reopening STDOUT
          exec "java -Xmx1024M -Xms1024M -jar #{filename} nogui"
        end

        print_pid

        @running = true
    end

    def print_pid
        puts "PID: #{pid}"
    end
    
    def stop
        if running
            Process.kill(9, pid)
        end
        @running = false
    end

    def get_server_filename(version)
        minecraft_server_file="minecraft_server.#{version}.jar"
    end
end

class MinecraftServerController < ApplicationController
    def index
        puts "Hello, world!"
        start_server
    end

    def start_server
        test_world = MinecraftWorld.new(
            name: "test world",
            directory: "/Users/chrisrice/MinecraftWorlds/testworld",
            version: "1.8.8")

        server = MinecraftServer.new
        server.start_world(test_world)

        # puts "The server will be up for 5 seconds"
        # sleep(5)
        # puts "Im going to stop in 5 seconds"
        # sleep(5)
        # server.stop
    end
end
