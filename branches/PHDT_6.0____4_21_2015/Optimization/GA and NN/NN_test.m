
if settings.normalized == 1
    MPG = std.MPG.std_MPG*net.MPG.MPG_net(x') + mean.MPG.mean_MPG
    NOx = (std.NOx.std_NOx*net.NOx.NOx_net(x') + mean.NOx.mean_NOx)
    HC = (std.HC.std_HC*net.HC.HC_net(x') + mean.HC.mean_HC)
    CO = (std.CO.std_CO*net.CO.CO_net(x') + mean.CO.mean_CO)
else
    MPG = net.MPG.MPG_net(x')
    NOx = net.NOx.NOx_net(x')
    HC = net.HC.HC_net(x')
    CO = net.CO.CO_net(x')  % g/mile
end