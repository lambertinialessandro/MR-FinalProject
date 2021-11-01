function roc = compute_roc(oTn, A, offset, i)
% Compute the roc vector of the i-th component of the robot.
%
% OUTPUT
% roc: CoM offset w.r.t. RF0

    arguments
        % Direct kinematics homogeneous matrix
        oTn (:, 4, 4) {}
        % Denavit-Hartenberg matrix
        A (:, 4, 4) {}
        % CoM offset
        offset (3, :) {}
        % i-th component to consider
        i {}
    end

    dk = oTn(:,:,i+1);
    lt = A(:,:,i+1);

    tloc = lt(1:3, 4);
    if i==1
        ric = simplify(tloc + offset(:, i));
        roc = ric;
        return
    end
    ric = simplify(offset(:, i));
    roc = simplify(dk * [ric;1]);
    roc = simplify(roc(1:3));
end
