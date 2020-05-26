% Dwelling heating needs graph
% Arie Taal, Baldiri Salcedo HHS


figure
plot(heating_needs.time/(24*3600),heating_needs.signals.values)
title('Heating power need')
ylabel('Heating power [W]')
xlabel('Time [days]')
xlim([0 max(heating_needs.time/(24*3600))])
grid


