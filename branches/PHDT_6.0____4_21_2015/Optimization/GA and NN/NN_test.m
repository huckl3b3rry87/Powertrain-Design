
if normalized.on == 1
    MPG = std.MPG.std_MPG*net.MPG.MPG_net(x') + mean.MPG.mean_MPG
    NOx = (std.NOx.std_NOx*net.NOx.NOx_net(x') + mean.NOx.mean_NOx)/1000
    HC = (std.HC.std_HC*net.HC.HC_net(x') + mean.HC.mean_HC)/1000
    CO = (std.CO.std_CO*net.CO.CO_net(x') + mean.CO.mean_CO)/1000
else
    MPG = net.MPG.MPG_net(x')
    NOx = net.NOx.NOx_net(x')/1000
    HC = net.HC.HC_net(x')/1000
    CO = net.CO.CO_net(x')/1000
end