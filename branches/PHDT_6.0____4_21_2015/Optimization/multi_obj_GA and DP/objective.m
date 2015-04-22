function Y = objective(~,varargin)

Y(1) = evalin('base','NOx');
Y(2) = evalin('base','CO');
Y(3) = evalin('base','HC');
Y(4) = -evalin('base','MPG'); % Negative for objective function

return
