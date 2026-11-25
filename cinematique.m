function[dtheta1_, X1_, Y1_, ay1_ ] = cinematique(u_,beta_, Parametre)

Lf = Parametre.Lf; %m
Lr = Parametre.Lr; %m
L = Lr + Lf;


Ti = 0; % temps initial et final
Tf = 100;
dt = 0.001;

T_ = (Ti : dt : Tf)'; %vecteur temps
Nbs = length(T_);

theta1_ = zeros(Nbs, 1); %angle de lacet en rad
dtheta1_ = zeros(Nbs, 1); %vitesse de lacet en rad/s

%Creation des variables de position du centre de gravite cinematique
X1_ = zeros(Nbs, 1);
Y1_ = zeros(Nbs, 1);

% Accélération latérale
ay1_ = zeros(Nbs, 1);

for i=1:(Nbs - 1)
    dtheta1_(i) = u_(i) * tan(beta_(i))/L; % u = ur en cinematique

    theta1_(i + 1) = theta1_(i) + dtheta1_(i) * dt; %integration
    
    X1_(i + 1) = X1_(i) + u_(i) * cos(theta1_(i)) * dt;
    Y1_(i + 1) = Y1_(i) + u_(i) * sin(theta1_(i)) * dt;

    ay1_(i) = u_(i) * (dtheta1_(i));
    
end

dtheta1_(Nbs) = u_(Nbs) * tan(beta_(Nbs))/L; %car il manquait une valeur pour dtheta

end