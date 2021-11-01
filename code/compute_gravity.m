function G = compute_gravity(q, mass, roc, g)
% Compute the gravity component of the dynamic model.
%
% OUTPUT
% G: gravity component

    arguments
        % Joints variables
        q (:, 1) {}
        % Vector with the mass of each component
        mass (:, 1) {}
        % CoM offset w.r.t. RF0
        roc (:, 3) {}
        % Gravity vector w.r.t. RF0
        g (3, 1) {}
    end

    U = 0;
    for i=1:size(mass, 1)
        % gravity component of the i-th component
        ui = -mass(i) * g' * roc(:, i);
        U = U + ui;
    end
    
    % jacobian of the gravity component
    G = jacobian(U, q)';
end
