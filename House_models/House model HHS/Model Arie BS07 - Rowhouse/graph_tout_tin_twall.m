% Outdoor, indoor and wall temperature graph
% Arie Taal, Baldiri Salcedo HHS

figure
plot(ToutTinTwall.time/(24*3600),ToutTinTwall.signals.values)
title('Outdoor, indoor and wall temperature')
ylabel('T [oC]')
xlabel('Time [days]')
xlim([0 max(ToutTinTwall.time/(24*3600))])
grid
legend('Toutdoor','Tindoor','Twall')

