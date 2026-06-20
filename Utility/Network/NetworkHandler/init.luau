local nh_context = require(script.nh_context)

if nh_context.run_context == "Server" then
	require(script.nh_server)
else
	require(script.nh_client)
end

return require(script.nh_init)
