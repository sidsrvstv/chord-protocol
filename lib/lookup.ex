defmodule Lookup do
    def lookup(keyId, nodeId, sourceID, successor, predecessor, hop_count,fingerTable) do

        if ( keyId > predecessor and (keyId <= nodeId or predecessor > nodeId ) ) do

            {1, nodeId, hop_count}
        else
            if ( successor < nodeId ) do 
                if (keyId > nodeId or keyId <= successor) do
                    {1, successor, hop_count + 1}
                else
                    next_n_Id = closest_preceding_node(keyId, nodeId, fingerTable, length(fingerTable) - 1)
                    {0, next_n_Id, hop_count + 1}
                end
            else
                if ( keyId > nodeId and keyId <= successor ) do
                    {1, successor, hop_count + 1}
                else
                    next_n_Id = closest_preceding_node(keyId, nodeId, fingerTable, length(fingerTable) - 1)
                    if next_n_Id == nil do
                        {0, successor, hop_count + 1}
                    else
                        {0, next_n_Id, hop_count + 1}
                    end
                end
            end
        end
    end

    def closest_preceding_node(_, nodeId, _, 0) do
        nodeId
    end

    def closest_preceding_node(keyId, nodeId, fingerTable, iter) do

        nodeId =
        if ( Enum.at(fingerTable, iter) < keyId) do
            Enum.at(fingerTable, iter)
        else
            if (Enum.at(fingerTable, iter) > keyId) do
                Enum.at(fingerTable, iter)
            else
                nil
            end
        end

        if nodeId != nil do
            nodeId
        else
            closest_preceding_node(keyId, nodeId, fingerTable, iter - 1)
        end
    end
end