function mu=mu_sol(sol)
    switch sol
        case "Beton sec"
            mu = 0.8 ;
        case "Beton mouillé"
            mu = 0.6;
        case "Gravier"
            mu = 0.5;
        case "Boue"
            mu = 0.2;
        otherwise
            error("Erreur le sol choisi n'existe pas");
    end
end