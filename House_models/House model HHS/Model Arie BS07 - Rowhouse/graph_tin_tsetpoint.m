% Indoor and setpoint temperature graph
% Arie Taal, Baldiri Salcedo HHS


figure
plot(TinTset.time/(24*3600),TinTset.signals.values)
title('Indoor and setpoint temperature')
ylabel('T [oC]')
xlabel('Time [days]')
xlim([0 max(TinTset.time/(24*3600))])
grid
legend('Tindoor','Tsetpoint')

