defmodule ChordProtocol.Network do

    def init(nodes, req) do
        num_nodes = String.to_integer(nodes)
        num_req = String.to_integer(req)
        #bug
        m = trunc( Float.ceil ( :math.log( num_nodes )/ :math.log(2) ) ) #Check if this is the right value

        max_val = :math.pow(2, m+3) |> trunc
        # IO.inspect max_val, label: "Max val is"

        # set = MapSet.new
        # set = Utility.generate_unique_ids(num_nodes, max_val, set)

        # nodes = MapSet.to_list(set)
        nodes = Utility.generate_nodelist_hashing(num_nodes)


        IO.inspect nodes, label: "Nodes in the list are"

        if length(nodes) < num_nodes do
            raise "Not enough nodes were created."
        end

        node_listSorted = :lists.sort(nodes)
        for i <- 0..num_nodes-1 do
            nodeId = Enum.at(node_listSorted, i) #elem(List.pop_at(node_listSorted, i), 0)
            nodeId_atom = Utility.convert_int_atom(nodeId)

            predecessor = if i == 0 do
                Enum.at(node_listSorted, num_nodes-1)
            else
                Enum.at(node_listSorted, i-1)
            end

            #predecessor = Enum.at(node_listSorted, i-1) #elem(List.pop_at(node_listSorted, i-1), 0)

            #IO.puts "Calling fingertable"
            fingerTable = Utility.fix_fingers(nodeId, node_listSorted, m+3)
            #IO.inspect fingerTable, label: "Returned fingerTable = "

            successor = if i == num_nodes-1 do
                Enum.at(node_listSorted, 0)
            else
                Enum.at(node_listSorted, i+1)
            end

            GenServer.start_link(Node, [nodeId, fingerTable, successor, predecessor, num_nodes, num_req, m], name: nodeId_atom)

            #IO.inspect nodeId_atom, label: "#{i} Created node with atom"

        end

        parent = self()
        hop_count_task = Task.async(fn -> get_total_hops(parent, num_nodes*num_req, 0, num_req, 0) end)
        :global.register_name(:mainproc, hop_count_task.pid)

        Enum.each(node_listSorted, fn(node) -> GenServer.cast(Utility.convert_int_atom(node), {:start_request}) end)

        Task.await(hop_count_task, :infinity)

        receive do
            {:total_hops, sum_hops, count_hops} -> avg_hops = sum_hops / count_hops #(num_nodes*num_req)
                                       IO.puts "Average hops taken by each actor: #{avg_hops}"
        end

        # sum_hops = get_total_hops(num_nodes,0)
        # # Process.sleep(10000)
        # # IO.puts "Came back in main"
        # avg_hops = sum_hops/num_nodes
        # IO.puts "Finished Execution!"
        # IO.puts "////////////////////////////////////////////////////////////"
        # IO.puts "Average hops taken by each actor: #{avg_hops}"
        # IO.puts "////////////////////////////////////////////////////////////"

    end

    def get_total_hops(parent, 0 ,sum, num_req, count_hops), do: send(parent, {:total_hops, sum, count_hops})

    def get_total_hops(parent, pending_req, sum, num_req, count_hops) do
        receive do
            {:hop_count, hops, destination, keyId} -> sum = sum + hops
                                  #IO.puts "Key #{keyId} reached the destination #{destination} in #{hops} hops."
                                  get_total_hops(parent, pending_req - 1, sum, num_req, count_hops+1)

        after
            2000*num_req -> send(parent, {:total_hops, sum, count_hops})
        end
    end
end
