local loader = {
    version = "0.1"
}

function loader.loadOnActor()
    local run_on_actor = run_on_actor or syn and syn.run_on_actor
    local queue_on_teleport = queue_on_teleport or syn and syn.queue_on_teleport

    if run_on_actor then
        for _, actor in next, getactors() do
            if actor.Name ~= "Instance" then
                run_on_actor(actor, modules.files.script)
            end
        end
    elseif queue_on_teleport then
        local localplayer = game:GetService("Players").LocalPlayer
        local teleportservice = game:GetService("TeleportService")
        local httpservice = game:GetService("HttpService")
        
        localplayer.OnTeleport:Connect(function(state)
            if state == Enum.TeleportState.InProgress then
                queue_on_teleport([[
                    local runService = game:GetService("RunService"); -- actor bypass by mickey#3373
                    local replicatedFirst = game:GetService("ReplicatedFirst");
        
                    replicatedFirst.ChildAdded:Connect(function(instance)
                        if instance:IsA("Actor") then
                            replicatedFirst.ChildAdded:Wait();
        
                            for _, child in next, instance:GetChildren() do
                                child.Parent = replicatedFirst;
                            end
                        end
                    end);
        
                    local old; old = hookmetamethod(runService.Stepped, "__index", function(self, index)
                        local indexed = old(self, index);

                        if index == "ConnectParallel" and not checkcaller() then
                            hookfunction(indexed, newcclosure(function(signal, callback)
                                return old(self, "Connect")(signal, function()
                                    return self:Wait() and callback();
                                end);
                            end));
                        end

                        return indexed;
                    end);
        
                    task.spawn(function()
                        local shared = getrenv().shared;
                        repeat task.wait() until shared.close;
                        hookfunction(shared.close, function() end);
                    end);
        
                    wait(7);
                ]] .. modules.files.script)
            end
        end)
        
        teleportservice:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    else
        print("loading failed")
    end
end

return loader
