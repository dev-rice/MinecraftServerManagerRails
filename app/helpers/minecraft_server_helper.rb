class MinecraftWorld
    attr_reader :name, :directory, :version

    def initialize(args)
        @name = args[:name]
        @directory = args[:directory]
        @version = args[:version]
    end

    def start(server)
        enter_world_dir
        server.start(version, name)
    end

    def enter_world_dir
        Dir.chdir(directory)
    end

    def log_filename
        File.join(directory, "logs", "latest.log")
    end

    def log_text
        log_contents = ""
        File.open(log_filename, "r") {|f|
            log_contents = f.read
        }
        log_contents
    end

end

class WorldsTable
    attr_reader :dbconn, :table_id

    def initialize(dbconn, table_id)
        @dbconn = dbconn
        @table_id = table_id

        create_if_not_exist
    end

    def create_if_not_exist
        if !this_table_exists?
            create
        end
    end

    def create
        dbconn.exec("CREATE TABLE #{table_id}(name text, path text, version text);")
    end

    def get_worlds()
        result = dbconn.exec("SELECT * FROM #{table_id};")
        worlds = {}
        result.each {|world_hash|
            world_hash_new = {name: world_hash["name"], directory: world_hash["path"], version: world_hash["version"]}
            worlds[world_hash["name"]] = MinecraftWorld.new(world_hash_new)
        }

        worlds
    end

    def get_world(name)
        world = get_worlds[name]
    end

    def this_table_exists?
        table_exists?(table_id)
    end

    def table_exists?(table_name)
        result = dbconn.exec("SELECT count(*) FROM information_schema.tables WHERE table_name = \'#{table_name}\';")
        count = result[0]["count"].to_i
        count != 0
    end
end

class ServerTable
    attr_reader :dbconn, :table_id

    def initialize(dbconn, table_id)
        @dbconn = dbconn
        @table_id = table_id

        create_if_not_exist
    end

    def create_if_not_exist
        if !this_table_exists?
            create
        end
    end

    def get_pid
        result = dbconn.exec("SELECT pid FROM #{table_id}")
        entry = result[0]

        entry["pid"].to_i
    end

    def get_world_name
        result = dbconn.exec("SELECT world_name FROM #{table_id}")
        entry = result[0]

        entry["world_name"]
    end

    def num_rows
        get_number_of_rows_in_table(table_id)
    end

    def is_active?
        num_rows > 0
    end

    def this_table_exists?
        table_exists?(table_id)
    end

    def create
        dbconn.exec("CREATE TABLE #{table_id}(pid int, running bool, world_name text);")
    end

    def create_entry(pid, name)
        dbconn.exec("INSERT INTO #{table_id} (pid, running, world_name) VALUES (#{pid}, true, \'#{name}\');")
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
        count = result[0]["count"].to_i
        count != 0
    end

end

class MinecraftServer
    attr_reader :pid, :running, :server_table, :worlds_table, :world

    def initialize(server_table, worlds_table)
        @server_table = server_table
        @worlds_table = worlds_table
        @running = false

        restore_if_active
    end

    def restore_if_active
        if server_table.is_active?
            restore
        end
    end

    def restore
        set_pid(server_table.get_pid)
        set_world_from_name(server_table.get_world_name)
    end

    def set_world_from_name(world_name)
        set_world(worlds_table.get_world(world_name))
    end

    def set_world(world)
        @world = world
    end

    def start_world(world)
        world.start(self)
    end

    def start(version, name)
        if !running
            run_server(version)
            server_table.create_entry(pid, name)
        end
    end

    def run_server(version)
        filename = get_server_filename(version)
        run_sever_command(filename)
    end

    def run_sever_command(filename)
        pid_temp = fork do
            exec java_command(filename)
        end

        set_pid(pid_temp)
    end

    def java_command(filename)
        "java -Xmx1024M -Xms1024M -jar #{filename} nogui"
    end

    def log_text
        if running
            world.log_text
        else
            ""
        end
    end

    def set_pid(pid_temp)
        @pid = pid_temp
        @running = true
    end

    def kill_server
        Process.kill(9, pid)
        @running = false
    end

    def stop
        if running
            server_table.delete_entry
            kill_server
            delete_log_file
        end
    end

    def get_server_filename(version)
        "minecraft_server.#{version}.jar"
    end
end

module MinecraftServerHelper
end
