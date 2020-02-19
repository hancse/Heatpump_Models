% Initialization Dwelling
% 10 July 2018
% Arie Taal, Baldiri Salcedo HHS


%% Predefined variables
 
rho_air=1.20;             % density air in [kg/m3]
c_air=1005;               % specific heat capacity air [J/kgK]
alpha_i_facade=8;
alpha_e_facade=23;
alpha_internal_mass=8;

%% Variables from Simulink model, dwelling mask

% Floor and internal walls construction.
% It is possible to choose between light, middle or heavy weight construction

if N_internal_mass==1       % Light weight construction 
   
    c_internal_mass=840;       % Specific heat capacity construction [J/kgK]
    th_internal_mass=0.1;       % Construction thickness [m]
    rho_internal_mass=500;     % Density construction in [kg/m3]
      
elseif  N_internal_mass==2  % Middle weight construction 
    
    c_internal_mass=840;        % Specific heat capacity construction [J/kgK]
    th_internal_mass=0.1;        % Construction thickness [m]
    rho_internal_mass=1000;     % Density construction in [kg/m3]
     
else                        % Heavy weight construction
         
    c_internal_mass=840;        % Specific heat capacity construction [J/kgK]
    th_internal_mass=0.2;        % Construction thickness [m]
    rho_internal_mass=2500;     % Density construction in [kg/m3]   
end

% Facade construction
% It is possible to choose between light, middle or heavy weight construction

if N_facade==1         % Light weight construction   
    c_facade=840           % Specific heat capacity construction [J/kgK]
    rho_facade=500;        % Density construction in [kg/m3]
    th_facade=0.1;         % Construction thickness [m] 
  
elseif  N_facade==2    % Middle weight construction       
    c_facade=840;          % Specific heat capacity construction [J/kgK]
    rho_facade=1000;       % Density construction in [kg/m3]
    th_facade=0.1;         % Construction thickness [m]

else                       % Heavy weight construction
    c_facade=840;          % Specific heat capacity construction [J/kgK]
    rho_facade=2500;       % Density construction in [kg/m3]
    th_facade=0.2;         % Construction thickness [m]
end

Aglass=sum(glass);                 % Sum of all glass surfaces [m2]
V_internal_mass=A_internal_mass*th_internal_mass;   % Volume floor and internal walls construction [m3]
qV=(n*V_dwelling)/3600;            % Ventilation, volume air flow [m3/s]
qm=qV*rho_air;                     % Ventilation, mass air flow [kg/s]

%% Dwelling temperatures calculation

% Calculation of the resistances
Rair_wall=1/(A_internal_mass*alpha_internal_mass); % Resistance indoor air-wall
U=1/(1/alpha_i_facade+Rc_facade+1/alpha_e_facade); % U-value indoor air-facade
Rair_outdoor=1/(A_facade*U+Aglass*Uglass+qm*c_air); % Resitance indoor air-outdoor air

% Calculation of the capacities
Cair=rho_internal_mass*c_internal_mass*V_internal_mass/2+ rho_air*c_air*V_dwelling; % Capacity indoor air + walls
Cwall=rho_internal_mass*c_internal_mass*V_internal_mass/2% Capacity walls

% State space equations
% dTair/dt=a11.Tair+a12.Twall+b11.Toutdoor+b12.Qinst+b13.Qinternal+b14.Qsolar
% dTwall/dt=a21.Tair+a22.Twall+b21.Toutdoor+b22.Qinst+b23.Qinternal+b24.Qsolar

% Calculation of the matrix elements
a11=-1/(Rair_wall*Cair)-1/(Rair_outdoor*Cair);
a12=1/(Rair_wall*Cair);
a21=1/(Rair_wall*Cwall);
a22=-1/(Rair_wall*Cwall);

b11=1/(Rair_outdoor*Cair);  % Toutdoor
b12=1/Cair;              % Q installation
b13=1/Cair;              % Q internal heat gains
b14=CF/Cair;             % Q solar radiation

b21=0;              % Toutdoor
b22=0;              % Q installation
b23=0;              % Q internal heat gains
b24=(1-CF)/Cwall    % Q solar radiation

% Calculation of the matrices
A=[a11 a12 ; a21 a22];
B=[b11 b12 b13 b14 ; b21 b22 b23 b24];
C=[1 0 ; 0 1 ]; % dummy T=T
D=[0 0 0 0; 0 0 0 0]; % dummy


