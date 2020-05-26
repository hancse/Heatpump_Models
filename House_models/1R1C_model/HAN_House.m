%% LOAD DATA

%{
-- EXPLANATION OF HOUSE DATA SIMULATIONS --

The inside temperature Tin of a dwelling depends on the following.
 - P_h   [W] : Heating through heaters/heat pumps;
 - P_w   [W] : Solar Irradiation through the glass windows;
 - P_amb [W] : Power gained/lost to the ambience which, in turn, is dependent on
 - T_amb [K] : Ambient Temperature;
 - P_gen [W] : Internal Generation (heat radiated by occupants, domestic appliances, etc).

The Dutch body of standards, NEN, provides the year-long data on ambient
temperature and solar irradiance at a geographical location. Solar
Irradiance is of 3 types: direct, reflected and diffused, each of which is
known from NEN, all summed up together to form the oslar irradiance term:
 - phi_s [W/m^2] : Solar Irradiance at a coordinate location.

With the knowledge of the coordinates of the house, irradiance data for
every hour, throughout the year is available at the house location. From
the knowledge of house structure, like glass coverage, ZTA value of the
glass, etc, as well as the knowledge of wind direction, the eventual impact
of solar irradiance on each of the 6 house faces, and consequently on the
temperature inside the house, is interpreted in the form of power coming
in, Pw. Thus, the data  of Ta and Pw is available on an hourly basis for
the entire year period.

Within the excel simulation environment, the house is subjected to a
staircase test input of Ph for the entire year period. The response of the
house constitutes the system output,Tin, temperature inside the house. All
this data of inputs and output is transferred from excel into a MATLAB data
structure file titled "HAN_HouseTest.m".

%}

clear,clc
load('HAN_HouseTest.mat')

%{
-- GREY BOX MODELING --
The discrete polynomial model is:
T_in(n+1) = T_in(n) + [1/RC]*[T_amb(n-1)-T_in(n)] + [1/C]*[P_h(n)+P_h(n)]

R : thermal resistance from the interior to the ambient.
C : heat capacity of the entire building.

The house is considered as a single zone, hence has a single temperature
measurement location, and a single value for every sample instance.

In grey-box modeling, the model parameters R & C are estimated using
measured data of the system. After this, the model needs to be validated
as well. To this end, the year long data of the houses split into two
independent sets, a 'training set' and a 'validation set'. The training set
is used to estimate the coefficients in the model equation, while the
validation set is where the model is ultimately put to test.
A point worth repeating is that data is sampled at every hour.

TRAINING SET:
Start : 01/01 00:00.
End : 30/01 23:00.
Number of hours = Number of sample points = 720.
VALIDATION SET
Start : 31/01 00:00.
End : 31/12 23:00.
Number of hours = Number of sample points = 8040.
%}

disp(['----------MODELING----------'])


%% MODEL TRAINING
%{
Data of the first 30 days (720 hours) is used as training set.
%}

disp(['- - - - - Start of Training Period'])

%{
Data of the first 30 days is used to train the model, i.e., estimate the
parameters, with satisfactory model performance.
From the Data structure, relevant quantities for the 30-day period is
extracted.
Ordinary Least Squares method is used to estimate the parameters.

The Phi matrix consists of the the data of the quantities associated with
the parameters.
Phi=[T_in , (T_amb-T_in) , (P_h+P_w)]

As a consequence of the nature of the model, T_in data points from the
second sample, onwards until the end of the set, are observed, using the
quantities whose range is from the first sample, until the second last
sample. This is because measurements at a certain sample hour dictate the
T_in at the next hour.
The array of estimated parameters is LS.
LS(2) = 1/RC ; LS(3) = 1/C.
%}

% Specifying the first (S) and last (E) sample points for training set
S=1;E=720;

% Extracting the quantities from  the Data struct for the training period 
P_h=Data.P_h(S:E,:);
P_w=Data.P_windows(S:E,:);
P_gen=Data.P_gen(S:E,:);
T_amb=Data.T_amb(S:E,:);
T_in=Data.T_in(S:E,:);

% Ordinary Least Squares Estimation of Parameters
T_meas=T_in(2:end,:);
Phi=[T_in(1:end-1,:),(T_amb(1:end-1,:)-T_in(1:end-1,:)),(P_w(1:end-1,:)+P_h(1:end-1,:))]; % Phi=[T_in(n),(T_amb(n)-T_in(n)),(P_w(n)+P_h(n))]
LS=Phi\T_meas;

% Interpreting R & C from LS
RC=1/LS(2);C=1/LS(3);
R=RC/C;

%{
The model performance is observed by predicting the model outputs with
these parameters, and compared with the actual outputs.
Model error 'e' gives the magnitude of error at each sample point, and can
be plotted for visual observation.
Another tool to compare predicted and actual outputs is a straight-off plot
between the two. A staight line would indicate equality between the two.
Hence this plot should be as close as possible to the straight line.
%}

% Predicted Output / Model Output
T_pred=Phi*LS;

% Model Error
e=T_meas-T_pred;
plot(e,'linewidth',2)
xlabel('Time [h]'),ylabel('Prediction Error [ºC]'),title('Model Error Over Training Period');
xlim([0 E]),ylim([-0.4 0.4])

% Prediction vs Measurement
figure,
plot(T_meas,T_pred,'x','color','r'),xlabel('Measured Temperature [K]'),ylabel('Predicted Temperature [K]')
title('Predicted vs Measured Value of House Temperature Over Training Period')

%{
Two metrics of model performance are Coefficient of Determination (Rsq) and
Root Mean Square Error (RMSE). The value of Rsq lies between 0 & 1. The
higher it is, the better the model. The intention is to get an Rsq of at
least 0.99. For RMSE, the lower it is, the better the model. All results
are displayed in the command window.
%}

% R-Sq Calculations over Training Period
T_Av=sum(T_meas)/size(T_meas,1);
SS_res=sum(e.^2); %Residual Sum of Squares
SS_tot=sum((T_meas-T_Av).^2); % Total Sum of Squares
Rsq=1-(SS_res/SS_tot);

% RMSE Calculations over Training Period
RMSE=sqrt((sum(e.^2)/size(e,1)));

% Displaying results
if Rsq>=0.99
    disp(['IDENTIFIED PARAMETERS : '])
    disp(['Envelope Resistance R_ia = ',num2str(R)])
    disp(['Interior Capacitance C_i = ',num2str(C)])
    disp(['Time Constant RC = ',num2str(RC)])
    disp(['PREDICTION PERFORMANCE : '])
    disp(['Coefficient of Determination over the Training Set = ',num2str(Rsq)])
    disp(['Root Mean Square Error over the Training Set = ',num2str(RMSE)])
    disp(['CONCLUSION : PARAMETERS IDENTIFIED, WITH HIGH PREDICTION ACCURACY'])
else
    disp(['CONCLUSION : PARAMETERS IDENTIFIED, WITH HIGH PREDICTION ACCURACY'])
end

disp(['- - - - - End of Training Period'])

%% MODEL VALIDATION
%{
Identified Parameters used to validate model over the remainder of the data set
%}
disp(['- - - - - Start of Model Validation'])

%{
To test the trained model, the remainder of the data set is used. This
constitutes data from the 31st day, until the last day of the year, a total
of 335 days.
The first data point in this set is the 721st hour, and the last is the
8760th hour.
From the Data structure, relevant quantities for the 335-day period is
extracted.
%}

% Specifying the first (S) and last (E) sample points for traivalidation set
S=721;E=8760;

% Extracting the quantities from the Data struct for the validation period 
P_h=Data.P_h(S:E,:);
P_w=Data.P_windows(S:E,:);
P_gen=Data.P_gen(S:E,:);
T_in=Data.T_in(S:E,:);
T_amb=Data.T_amb(S:E,:);

% Predicted Output over the Validation Period
T_pred=(T_in(1:end-1,:))+((1/RC)*(T_amb(1:end-1,:)-T_in(1:end-1,:)))+((1/C)*(P_w(1:end-1,:)+P_h(1:end-1,:)));

% Actual/Measured Output
T_meas=Data.T_in(S+1:E,:);

%{
Just as in training period, model performance is observed by predicting the
model outputs with these parameters, and compared with the actual outputs.
Model error 'e' gives the magnitude of prediction error at each sample
point, and is plotted for visual observation. Another tool to compare
predicted and actual outputs is a straight-off plot between the two. A
staight line would indicate equality between the two. Hence this plot
should be as close as possible to the straight line.
%}

% Prediction Error
e=T_meas-T_pred;
plot(e,'linewidth',2)
xlabel('Time [h]'),ylabel('Prediction Error [ºC]'),title('Model Error Over Validation Period');
xlim([0 E-S]),ylim([-0.8 0.8])


% Prediction vs Measured Values
figure,
plot(T_meas,T_pred,'x','color','b')
xlabel('Measured Temperature [K]'),ylabel('Predicted Temperature [K]')
title('Predicted vs Measured Value of House Temperature Over Validation Period')

%{
The same two metrics of model performance are used in Validation as well.
Coefficient of Determination (Rsq), and Root Mean Square Error (RMSE).
All results are displayed in the command window.
%}

% Rsq Calculations over Validation Period
T_AV=sum(T_meas)/size(T_meas,1);
SS_res=sum(e.^2);
SS_tot=sum((T_meas-T_AV).^2);
Rsq=1-(SS_res/SS_tot);

% RMSE Calculations over Validation Period
RMSE_V=sqrt((sum(e.^2)/size(e,1)));

% Displaying results
display(['MODEL PERFORMANCE : '])
disp(['Coefficient of Determination Over the Validation Set = ',num2str(Rsq)])
disp(['Root Mean Square Error over the Validation Set = ',num2str(RMSE_V)])

if Rsq>=0.99
    disp(['CONCLUSION : MODEL DEEMED VALID, WITH HIGH PREDICTION ACCURACY'])
else
    disp(['CONCLUSION : MODEL NOT VALID, INSUFFICIENT PREDICTION ACCURACY'])
end

disp(['- - - - - End of Model Validation'])
disp([' '])

%% STATE SPACE FORMAT OF MODEL

disp(['- - - - - State Space Model'])

%{
The validated model can now be represented in state space format, This will
eventually help in designing the MPC, as MPS's work best with State Space
models.

State Equation:
T_in(n+1) = [1-1/RC]*T_in(n) + [1/C , 1/C , 1/RC]*[P_h ; P_w ; T_amb]
Output Equation:
Y(n)=[1]*T_in(n)

Am, Bm, Cm, and Dm are the State Space matrices.

The 'ss' command is used to formulate a state-space model. Sample time is
3600 seconds, i.e., 1 hour.
%}

Am=[1-(1/RC)]; Bm=[1/C,1/C,1/RC]; Cm=[1]; Dm=[0,0,0];

sys=ss(Am,Bm,Cm,Dm,3600)

Data.sys=sys

%{
This concludes the modeling phase of the work. The State Space Model is now
used in the MPC Designer App of Matlab to design and tune an MPC. Pictorial
descriptions of the designing steps are included in the report.
Simulations with the resulting designed and tuned controller is described
in the Matlab file "HAN_MPCscript.m".
%}

disp(['---------END OF MODELING---------'])
disp([' '])

%% MPC DESIGN

disp(['----------MPC DESIGN & SIMULATIONS----------'])

%{
The State Space Model 'sys' is used to design the MPC, in the MPC Designer
app.
Uncomment the command to open the designing app, and carry out the
designing steps.
The next section contains script for a designed and tuned MPC. The MPC
settings can be played with over there as well.
%}

% mpcDesigner(sys)

%{
In the MPC Structure tab in the app, P_h is set as the MV, while T_amb and
P_w are set as MDs. The MPC app reconfigures the state space model
internally to assign the input channels in a manner conforming to this MV &
MD setting. The dynamics and the model paramters stay the same in the
reconfigured model. All that changes is the input channel assigning. This
reconfigured model, sys_C, is the one that the controlle is finally
simulated on.Design and tuning steps are detailed in the report.
%}

%% MPC SIMULATIONS

%{
Once the MPC is designed and tuned in the app, the script is exported. The
controller can now be simulated for a prolonged duration with real
disturbance data.
The reconfigured model with appropriate channel assignment 'sys_C', is
loaded onto the workspace.
%}
sys_C=Data.sys_C;

%{
NDays is the number of number of days the simulation is decided to be
carried out for. 
%}
NDays=20;

%{
The reference set points for one day is set as 'Ref', and its values are
according to pre-known daily requirements. The single-day array is repeated
over the entire simulation period using the repmat function. This repeated
array serves as the set points for the NDays period.
%}
Ref=[16;16;16;16;16;16;16;20;20;20;20;20;20;20;20;20;20;20;20;20;20;20;20;20];
mpc1_RefSignal=repmat(Ref,NDays,1);

%{
As mentioend, real disturbance data is used for simulations. Solar
Irradiance and Ambient Temperature for the NDays period are put together
into an MD signal matrix.
%}
T_a=Data.T_amb(1:24*NDays); P_w=Data.P_windows(1:24*NDays);
mpc1_MDSignal=[P_w,T_a];

%{
mpc1_RefSignal is the reference signal for the simulation period.
mpc1_MDSignal is the MD signal containing both the disturbances included
within. What follows is the mpc script that comes out of the app.
%}


%{
mpc1 is created as the MPC controller object with sample time of 3600
seconds. The plant is sys_C, as expected.
%}
mpc1 = mpc(sys_C, 3600);

%{
Within mpc1, the different settings of the MPC are set as shown below. This
includes features such as constraints, horizon lengths, etc. Note that the
values of each of these comes out of automatically post-contrller design.
%}

% Prediction and Control Horizons
mpc1.PredictionHorizon = 3;
mpc1.ControlHorizon = 2;

% Nominal values for Inputs (U) and Outputs (Y)
% mpc1.Model.Nominal.U = [0;500;15];
% mpc1.Model.Nominal.Y = 20;

mpc1.Model.Nominal.U = [0;100;10];
mpc1.Model.Nominal.Y = 16;

% mpc1.Model.Nominal.U = [0;0;0];
% mpc1.Model.Nominal.Y = 16;

% Scale factors for output (OV) - Adjusted as per Deisgn Review Suggestions
mpc1.OV(1).ScaleFactor = 0.001;

% Constraints for MV – Limits on practical Heat Pump Operations
mpc1.MV(1).Min = 0;
mpc1.MV(1).Max = 6000;

% Overall Adjustment Factor Applied to Weights
beta = 7.3891;

% Weights
mpc1.Weights.MV = 0*beta;
mpc1.Weights.MVRate = 0.1/beta;
mpc1.Weights.OV = 15*beta;
mpc1.Weights.ECR = 100000;

% Simulation Options
options = mpcsimopt();
options.RefLookAhead = 'on';
options.MDLookAhead = 'off';
options.Constraints = 'on';
options.OpenLoop = 'off';

%{
With settings completed, closed loop simulation is done. Three simulation
outputs are:
T_in_MPC : temperature inside the house with MPC control;
t : simulation time;
P_h_MPC : Heating action by the used MPC control.
%}

[T_in_MPC,t,P_h_MPC]=sim(mpc1, 24*NDays, mpc1_RefSignal, mpc1_MDSignal, options);

%{
Simulation results need to be plotted for visual assessment.
%}
% plot(P_h_MPC,'linewidth',2)
% xlabel('Time (h)'),ylabel('Heating Provided - P_{h} [W]')
% title('Room Heating (Controller Effort)')
% xlim([0 24*NDays]),ylim([-100 6100])

figure,hold all
plot(mpc1_RefSignal,'linewidth',2),plot(T_in_MPC,'linewidth',2)
xlabel('Time (h)'),ylabel('Temperature - T_{in} [ºC]')
title('House Internal Temperature - Reference & Response')
xlim([0 24*NDays])
legend('Reference','Response','Location','northwest')

disp(['---------END OF MPC SIMULATIONS---------'])
disp([' '])

%% ENERGY COST COMPARISON

disp(['----------MPC vs FEEDBACK CONTROL----------'])

%{
The designed MPC’s performance needs to be assessed in comparison with
conventional feedback control. The results of MPC simulation reveal the
heating requirements on the entire simulation duration. For conventional
feedback control, closed loop simulations in the excel environment gives
the energy consumption profile. A comparison of the annual energy
requirements in feedback control, with the current MPC control, is a good
test of the MPC.
Data of feedback control is extracted from excel simulations, and is stored
in the mat file.
P_h_fb : Heating as per feedback control.
T_in_fb : House internal temperature with feedback control.
Actuator in current MPC-based system is assumed to have an efficiency of
100%. This means that 100W of energy is consumed by it to provide 100W of
heating. Not ideal, but a start.
%}

%{
Just in case the simulation done in the previous section was not for the
entire year duration, the MPC is simulated again for the entire year's
duration.
%}
mpc1_AnnualRefSignal=repmat(Ref,365,1);
mpc1_AnnualMDSignal=[Data.P_windows,Data.T_amb];
[Tin_MPC,t_annual,P_h_MPC]=sim(mpc1, 24*365, mpc1_AnnualRefSignal, mpc1_AnnualMDSignal, options);


%{
A visual comparison of the controller effort in both cases will indicate
when and where majority of the difference in control operation lies.
%}
figure,hold all
subplot(2,1,1),plot(Data.P_h_fb,'linewidth',0.5),
title('Controller Effort with Feedback Control')
xlabel('Time [h]'),ylabel('P_h [W]')
xlim([0 24*365]),ylim([-100 6100])

subplot(2,1,2),plot(P_h_MPC,'linewidth',0.5)
title('Controller Effort with MPC Control')
xlabel('Time [h]'),ylabel('P_h [W]')
xlim([0 24*365]),ylim([-100 6100])

%{
Mean Annual Controller Effort for both cases is also a quantitative
comaprison tool.
%}
Mean_P_h_fb=mean(Data.P_h_fb);
Mean_P_h_MPC=mean(P_h_MPC);
disp(['Mean Annual Energy Controller Effort - Feedback = ',num2str(Mean_P_h_fb),' W'])
disp(['Mean Annual Energy Controller Effort - MPC = ',num2str(Mean_P_h_MPC),' W'])
disp(['Reduction in Mean Annual Energy Controller Effort = ',num2str(Mean_P_h_fb-Mean_P_h_MPC),' W'])

%{
Summing up the power required at every instance for the entire simulation
period gives the annual energy requirements.
%}
AnnualEnergy_Feedback=sum(Data.P_h_fb);
AnnualEnergy_MPC=sum(P_h_MPC);
disp(['Annual Energy Consumption with Feedback Control = ',num2str(AnnualEnergy_Feedback*10^-6),' MWh'])
disp(['Annual Energy Consumption with MPC = ',num2str(AnnualEnergy_MPC*10^-6),' MWh'])

%{
The difference in Energy consumption through both controls is a picture of
imporvement provided by MPC.
%}
AnnualEnergy_Saving=AnnualEnergy_Feedback-AnnualEnergy_MPC;

disp(['Energy Saved Annually with MPC = ',num2str(AnnualEnergy_Saving*10^-6),' MWh'])

%{
To introduce the cost factor in the reduction of energy, the average price
of 20 cents per kWh (=€0.20/kWh) is used to calculate the expected annual savings in
monetary units.
%}

Rate_kWh=0.20;
AnnualCosts_Saving=Rate_kWh*AnnualEnergy_Saving*10^-3;

disp(['Expected Annual Cost Saving with MPC = €',num2str(round(AnnualCosts_Saving,2)),'/-'])


disp(['---------END OF MPC vs FEEDBACK CONTROL---------'])
disp([' '])