function[delta_, deltaf_, deltar_, dtheta_, X_, Y_, ay_] = dynamique(u_,beta_, type_de_contact, glr, glf, mu, Parametre)

m = Parametre.m ; %kg
g = 9.81; % m/s^2
Iz = Parametre.Iz; %kg/m^2
Lf =  Parametre.Lf; %m
Lr = Parametre.Lr; %m
L = Lr + Lf;
Cf = Parametre.Cf; %N/rad
Cr = Parametre.Cr; %N/rad
Kxf = Parametre.Kxf; % N/m
Kyf = Parametre.Kyf; % N/m
Kxr = Parametre.Kxr;
Kyr = Parametre.Kyr;

Fzr = m * g * Lf / L ; %N
Fzf = m * g * Lr / L ; %N

Ti = 0; % temps initial et final
Tf = 100;
dt = 0.001;

T_ = (Ti : dt : Tf)'; %vecteur temps
Nbs = length(T_);

theta_ = zeros(Nbs, 1); %angle de lacet en rad
dtheta_ = zeros(Nbs, 1); %vitesse de lacet en rad/s
d2theta_ = zeros(Nbs, 1); %acceleration de lacet rad/s^2

delta_ = zeros(Nbs, 1); %angle de derive global en rad
ddelta_ = zeros(Nbs, 1); %derivee angle de derive en rad/s

deltar_ = zeros(Nbs, 1); %angle de derive arriere en rad
deltaf_ = zeros(Nbs, 1); %angle de derive avant en rad



%Creation des variables de position du centre de gravite dynamique
X_ = zeros(Nbs, 1);
Y_ = zeros(Nbs, 1);

% Accélération latérale
ay_ = zeros(Nbs, 1); %dynamique

%Glissement longitudinal
glr_ = glr * ones(Nbs, 1);
glf_ = glf * ones(Nbs, 1);

sigmar_ = zeros(Nbs, 1);
sigmaf_ = zeros(Nbs, 1);
taur_ = zeros(Nbs, 1);
tauf_ = zeros(Nbs, 1);

%def des phenomenes de glissements
%Effort longitudinaux et lateraux des roues
Fxr_ = zeros(Nbs, 1);
Fxf_ = zeros(Nbs, 1);
Fyr_ = zeros(Nbs, 1);
Fyf_ = zeros(Nbs, 1);


for i=1:(Nbs - 1)
    %Defintion des variables pour pouvoir mieux debuger
    delta_0 = delta_(i);
    dtheta_0 = dtheta_(i);
    u_0 = u_(i);
    beta_0 = beta_(i);
    theta_0 = theta_(i);
    X_0 = X_(i);
    Y_0 = Y_(i);

    %{
    Pour le cas lineaire avec saturation
    [dthetarsg_,~, ~, ~ ] = cinematique(u_,beta_);
    dthetarsg_0 = dthetarsg_(i);
    %}

    %Arriere
    glr_0 = glr_(i);
    sigmar_0 = sigmar_(i);
    taur_0 = taur_(i);
    Fxr_0 = Fxr_(i);
    Fyr_0 = Fyr_(i);
    %Avant
    glf_0 = glf_(i);
    sigmaf_0 = sigmaf_(i);
    tauf_0 = tauf_(i);
    Fxf_0 = Fxf_(i);
    Fyf_0 = Fyf_(i);
    

    if delta_0 > -pi/2 && delta_0 < pi/2

        %modele pneu et angles de derive locaux
        deltaf_0 = - beta_0 + atan(tan(delta_0) + (Lf * dtheta_0) / u_0);
        deltar_0 = atan(tan(delta_0) - (Lr * dtheta_0) / u_0);

        %def des phenomene de glissements
        %cas linéaire
        if type_de_contact == 0
            Fxf_0 = Cf * deltaf_0* sin(beta_0);
            Fyf_0 =  - Cf * deltaf_0 * cos(beta_0);
            Fxr_0 = 0;
            Fyr_0 = - Cr * deltar_0;
        elseif type_de_contact == 1
            %Arriere
            %glr_0 = (dthetarsg_0 - u_0 * cos(deltar_0)/ Rdyn)/max(abs(dethetarsg_0),abs(u_0 * cos(deltar_0)/ Rdyn));
            sigmar_0 = ((1-glr_0) * mu * Fzr)/ (2 * sqrt(Kxr^2 * glr_0^2 + Kyr^2 * tan(deltar_0)^2));
            if sigmar_0 < 1
                taur_0 = (2 - sigmar_0) * sigmar_0;
            else
                taur_0 = 1;
            end
            if glr_0 ~= 1
                Fxr_0 = Kxr * glr_0 * taur_0 / (1 - glr_0);
                Fyr_0 = - Kyr * tan(deltar_0) * taur_0 / (1 - glr_0);
            end

            %Avant
            %glf_0 = (dthetarsg_0 - u_0 * cos(beta_0 - deltaf_0)/ Rdyn)/max(abs(dethetarsg_0),abs(u_0 * cos(deltaf_0)/ Rdyn));
            sigmaf_0 = ((1-glf_0) * mu * Fzf)/ (2 * sqrt(Kxf^2 * glf_0^2 + Kyf^2 * tan(deltaf_0)^2));
            if sigmaf_0 < 1
                tauf_0 = (2 - sigmaf_0) * sigmaf_0;
            else
                tauf_0 = 1;
            end
            if glf_0 ~= 1
                Fxf_0 = -(Kxf * glf_0 * tauf_0 / (1 - glf_0))* sin(beta_0);
                Fyf_0 = - (Kyf * tan(deltaf_0) * tauf_0 / (1 - glf_0))*cos(beta_0);
            end
        end
    
        %equations 
        d2theta_0 = (- Lr * Fyr_0 + Lf * Fyf_0) / Iz;
        ddelta_0 = (-(Fxf_0 + Fxr_0 )*sin(delta_0) + (Fyr_0 + Fyf_0) * cos(delta_0))/ (m * u_0) - dtheta_0;
    
    
        %integration 
        delta_1 = delta_0 + ddelta_0 * dt;
        dtheta_1 = dtheta_0 + d2theta_0 * dt;
        theta_1 = theta_0 + dtheta_0 * dt;
        
        %trajectoire
        X_1 = X_0 + u_0 * cos(theta_0 + delta_0) * dt;
        Y_1 = Y_0 + u_0 * sin(theta_0 + delta_0) * dt;
        
        %Accélération laterale
        ay_0 = u_0 * (dtheta_0 + ddelta_0);
    
        %On enregistre les valeurs calculees dans les vecteurs
        sigmaf_(i) = sigmaf_0;
        sigmar_(i) = sigmar_0;
        tauf_(i) = tauf_0;
        taur_(i) = taur_0;
        glr_(i) = glr_0;
        glf_(i) = glf_0;
        deltaf_(i) = deltaf_0;
        deltar_(i) = deltar_0;
        Fxf_(i) = Fxf_0;
        Fyf_(i) = Fyf_0;
        Fxr_(i) = Fxr_0;
        Fyr_(i) = Fyr_0;
        d2theta_(i) = d2theta_0;
        ddelta_(i) = ddelta_0;
        delta_(i + 1) = delta_1;
        dtheta_(i + 1) = dtheta_1;
        theta_(i + 1) = theta_1;
        X_(i + 1) = X_1;
        Y_(i + 1) = Y_1;
        ay_(i) = ay_0;

    else
        error('L''angle de braquage doit être compris entre -pi/2 et pi/2.');
    end
            
end

%Dernier point des angles
deltaf_(Nbs) = beta_(Nbs) - delta_(Nbs) - (Lf * dtheta_(Nbs)) / u_(Nbs);
deltar_(Nbs) = - delta_(Nbs) + (Lr * dtheta_(Nbs)) / u_(Nbs);
ay_(Nbs) = u_(Nbs) * (dtheta_(Nbs) + ddelta_(Nbs));

end