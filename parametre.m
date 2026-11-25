function Parametre = parametre(nom_vehicule)
    switch nom_vehicule
        case "Peugeot"
            % Pour un peugeot 208 phase 1 
            % Pneumatiques 195/55 R16
            % Rtheo = 0.3105; %m
            % Rdyn = Rtheo*0.95; %m 
            % on perd entre 5 et 10 pourcents par rapport au rayon theorique a cause des efforts sur le pneu
            Parametre.m = 1050; % masse du vehicule (kg)
            Parametre.Iz = 1600; % moment d'inertie en lacet(kg/m^2)
            % Empattement 
            Parametre.Lf = 0.931; % avant (m)
            Parametre.Lr = 1.609; % arriere (m)
            % Rigidites de derive
            Parametre.Cr = 70000; % avant (N/rad)
            Parametre.Cf = 120000; % arriere (N/rad)
            % Raideurs longitudinales et laterales
            Parametre.Kxr = 70000; % N/m
            Parametre.Kyr = 70000; % N/m
            Parametre.Kxf = 120000; % N/m
            Parametre.Kyf = 120000; % N/m
            % Rapport de demultiplication direction
            Parametre.id = 16.2; 
        case "Ferrari"
            % Ferrari 488 GTB
            Parametre.m = 1475; % masse (kg)
            Parametre.Iz = 2500; % inertie en lacet (kg.m^2)
            % Empattement 
            Parametre.Lf = 1.418; % avant (m)
            Parametre.Lr = 1.232; % arriere (m)
            % Rigidites de derive 
            Parametre.Cf = 120000; % avant (N/rad)
            Parametre.Cr = 140000; % arrière (N/rad)
            % Raideurs longitudinales et laterales
            Parametre.Kxr = 140000; % N/m
            Parametre.Kyr = 140000; % N/m
            Parametre.Kxf = 120000; % N/m
            Parametre.Kyf = 120000; % N/m
            % Rapport de demultiplication direction
            Parametre.id = 14; 
        otherwise
            error("Le véhicule choisi n'existe pas");
    end
end