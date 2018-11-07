defmodule Node do
    use GenServer

    def init([nodeId, fingerTable, successor, predecessor, num_nodes, num_req, m]) do
        {:ok, {nodeId, fingerTable, successor, predecessor, num_nodes, num_req, m, 0}}
    end

    def handle_cast({:start_request}, state) do
        #IO.inspect state
        {nodeId, fingerTable, successor, predecessor, num_nodes, num_req, m, hops} = state

       #  IO.inspect "Starting requests"

        nodes = Utility.generate_nodelist_hashing(num_nodes)
        keys = generateRandomKeys( num_req, nodes,  m)

        # IO.inspect keys, label: "Keys generated for #{nodeId} are "

        hopCount = 0
        Enum.each(keys, fn(key) ->
            GenServer.cast(Utility.convert_int_atom(nodeId), {:message, key, nodeId, hopCount})
            Process.sleep(1000)
        end)
        {:noreply, {nodeId, fingerTable, successor, predecessor, num_nodes, num_req, m, hops}}
    end

    def handle_cast({:message, key, sourceId, hopCount}, state) do
        {nodeId, fingerTable, successor, predecessor, num_nodes, num_req, m, hops} = state

        {foundKey, result, hops} = Lookup.lookup(key, nodeId, sourceId, successor, predecessor, hopCount, fingerTable) #Fix lookup
        #IO.puts "Result of hop is #{foundKey}, #{result}, #{hops}"
        if foundKey == 1 do
            GenServer.cast(Utility.convert_int_atom(sourceId), {:foundKey, result, key, hops})
        else
            #IO.puts "Hopping message #{key} to #{result}"
            GenServer.cast(Utility.convert_int_atom(result), {:message, key, nodeId, hops})
        end

        {:noreply, {nodeId, fingerTable, successor, predecessor, num_nodes, num_req, m, hops}}
    end

    def handle_cast({:foundKey, destination, keyId, hopCount}, state) do
        {nodeId, fingerTable, successor, predecessor, num_nodes, num_req, m, node_hops} = state

        #IO.puts "Key #{keyId} reached the destination #{destination} in #{hopCount} hopCount."

        send(:global.whereis_name(:mainproc), {:hop_count, hopCount, destination, keyId})
        # hops = prev_hops + hopCount
        # if num_req == 1 do
        #     average = hops/num_nodes
        #     IO.puts "Average inside the node #{nodeId} = #{average}"
        #     send(:global.whereis_name(:mainproc), {:hop_count, hops})
        # end
        {:noreply, {nodeId, fingerTable, successor, predecessor, num_nodes, num_req-1, m, node_hops}}
    end

    def handle_call(:is_active , _from, state) do
        {nodeId, fingerTable, successor, predecessor, num_nodes, num_req, m, hops} = state

        {:noreply, {nodeId, fingerTable, successor, predecessor, num_nodes, num_req, m}}
    end

    def handle_info({:DOWN, _, :process, pid, _}, state) do
        {:noreply, remove_pid(state, pid)}
    end

    def remove_pid(state, pid_to_remove) do
        remove = fn {_key, pid} -> pid  != pid_to_remove end
        Enum.filter(state, remove) |> Enum.into(%{})
    end

    def generateRandomKeys(num_req, nodes, m) do
        max_val = :math.pow(2, m+3) |> trunc
        # max_val = :math.pow(2, 16) |> trunc
        #keys = []Enum.to_list 1..10
        full_list = Enum.to_list 1..max_val
        set_of_values = full_list -- nodes
        key_set = MapSet.new
        key_set = generate_ids( num_req, set_of_values, key_set)

        keys = MapSet.to_list(key_set)
        # IO.inspect keys

    end

    def generate_ids(num, set_of_values, set) do
        if (MapSet.size(set) < num) do
            set = MapSet.put(set, get_rand_id(set_of_values))
            generate_ids(num,set_of_values , set)
        else
            set
        end
    end

    def get_rand_id(set_of_values) do
        Enum.random(set_of_values)
        #:random.uniform(max_val)
    end


end
