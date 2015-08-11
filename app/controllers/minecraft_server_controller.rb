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

class ServerTable
    attr_reader :dbconn, :table_id

    def initialize(dbconn, table_id)
        @dbconn = dbconn
        @table_id = table_id

        if !this_table_exists?
            create
        end
    end

    def get_pid
        result = dbconn.exec("SELECT pid FROM #{table_id}")
        entry = result[0]

        entry["pid"].to_i
    end

    def num_rows
        get_number_of_rows_in_table(table_id)
    end

    def this_table_exists?
        table_exists?(table_id)
    end

    def create
        dbconn.exec("CREATE TABLE #{table_id}(pid int, running bool);")
    end

    def create_entry(pid)
        dbconn.exec("INSERT INTO #{table_id} (pid, running) VALUES (#{pid}, true);")
    end

    def delete_entry
        pid = get_pid
        dbconn.exec("DELETE FROM #{table_id} WHERE pid = #{pid};")
    end

    def get_number_of_rows_in_table(table_name)
        result = dbconn.exec("SELECT * FROM #{table_name};")

        result.ntuples
    end

    def table_exists?(table_name)
        result = dbconn.exec("SELECT count(*) FROM information_schema.tables WHERE table_name = \'#{table_name}\';")
        count = result[0]["count"]

        count != 0
    end

end

class MinecraftServer
    attr_reader :pid, :running, :server_table

    def initialize(server_table)
        @server_table = server_table
        @running = false

        restore_if_running
    end

    def restore_if_running
        num_rows = server_table.num_rows
        if (num_rows != 0)
            restore
        end
    end

    def restore
        set_pid(server_table.get_pid)
    end

    def start_world(world)
        world.start(self)
    end

    def start(version)
        if !running
            filename = get_server_filename(version)
            run_sever_command(filename)
            server_table.create_entry(pid)
        end
    end

    def run_sever_command(filename)
        pid_temp = fork do
          exec "java -Xmx1024M -Xms1024M -jar #{filename} nogui"
        end
        set_pid(pid_temp)
    end

    def set_pid(pid_temp)
        @pid = pid_temp
        @running = true
    end

    def kill_server
        Process.kill(9, pid)
        @running = false
    end

    def print_pid
        puts "PID: #{pid}"
    end

    def stop
        if running
            server_table.delete_entry
            kill_server
        end
    end

    def get_server_filename(version)
        minecraft_server_file="minecraft_server.#{version}.jar"
    end
end


require 'pg'

class MinecraftServerController < ApplicationController
    attr_reader :server, :conn, :server_table

    def initialize
        initialize_db_connection
        @server_table = ServerTable.new(conn, 'server')
        @server = MinecraftServer.new(server_table)
    end

    def initialize_db_connection
        @conn = PG::Connection.open(:dbname => 'MinecraftServerManagerRails_development')
        puts @conn.error_message
    end

    def start_server
        test_world = MinecraftWorld.new(
            name: "test world",
            directory: "/Users/chrisrice/MinecraftWorlds/testworld",
            version: "1.8.8")
        if server
            server.start_world(test_world)
        else
            puts "server does not exist"
        end
    end

    def stop_server
        if server
            server.stop
        else
            puts "server does not exist"
        end
    end
end
