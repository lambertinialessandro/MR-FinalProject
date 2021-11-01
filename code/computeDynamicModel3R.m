function [M, cqdq, gq] = computeDynamicModel3R(oTn, A, m, r, I, Q, dQ, Q_s)
% Compute the dynamic model of the 3R leg with the Moving Frames method.
%
% OUTPUT
% M: Inertia Matrix
% cqdq: Coriolis and Centrifugal terms
% gq: Gravity term

    arguments
        % Direct kinematics homogeneous matrix
        oTn (4, 4, :) {}
        % Denavit-Hartenberg matrix
        A (4, 4, :) {}
        % mass vector
        m (1, :) {}
        % Center of mass of each link
        r (3, :) {}
        % Inertia matrix
        I (3, :) {}
        % Joints variables
        Q (1, :) {}
        % derivate Joints variables
        dQ (1, :) {}
        % Joints variables of the leg
        Q_s (1, :) {}
    end

    sigma = [0, 0, 0];
    N = 3;

    R01 = oTn(1:3, 1:3, 2);
    R12 = oTn(1:3, 1:3, 3);
    R23 = oTn(1:3, 1:3, 4);

    r0_01 = oTn(1:3, 4, 2);
    r1_12 = oTn(1:3, 4, 3);
    r2_23 = oTn(1:3, 4, 4);

    m1 = m(1);
    r1_1c1 = r(:, 1);
    I1c1 = I(:, 1:3);
    
    m2 = m(2);
    r2_2c2 = r(:, 2);
    I2c2 = I(:, 4:6);
    
    m3 = m(3);
    r3_3c3 = r(:, 3);
    I3c3 = I(:, 7:9);
    
    W00 = [0; 0; 0];
    V00 = [0; 0; 0];
    Z00 = [0; 0; 1];

    W11 = (R01'*(W00+(1-sigma(1))*dQ(1)*Z00));
    V11 = (R01'*V00+sigma(1)*dQ(1)*Z00+cross(W11, R01'*r0_01));
    V1c1 = (V11+cross(W11, r1_1c1));
    T1 = simplify(1/2*m1*norm(V1c1)^2+1/2*W11'*I1c1*W11);

    W22 = (R12'*(W11+(1-sigma(2))*dQ(2)*Z00));
    V22 = (R12'*V11+sigma(2)*dQ(2)*Z00+cross(W22, R12'*r1_12));
    V2c2 = (V22+cross(W22, r2_2c2));
    T2 = simplify(1/2*m2*norm(V2c2)^2+1/2*W22'*I2c2*W22);

    W33 = (R23'*(W22+(1-sigma(3))*dQ(3)*Z00));
    V33 = (R23'*V22+sigma(3)*dQ(3)*Z00+cross(W33, R23'*r2_23));
    V3c3 = (V33+cross(W33, r3_3c3));
    T3 = simplify(1/2*m3*norm(V3c3)^2+1/2*W33'*I3c3*W33);
    T = T1 + T2 + T3;

    m11 = simplify(diff(T, 2, dQ(1)));
    m22 = simplify(diff(T, 2, dQ(2)));
    m33 = simplify(diff(T, 2, dQ(3)));

    m12 = simplify(diff(diff(T,dQ(1)),dQ(2)));
    m13 = simplify(diff(diff(T,dQ(1)),dQ(3)));
    m23 = simplify(diff(diff(T,dQ(2)),dQ(3)));

    M = [m11 m12 m13;
         m12 m22 m23;
         m13 m23 m33];

    % C(q, dq)
    M1 = M(:, 1);
    M2 = M(:, 2);
    M3 = M(:, 3);

    j1 = jacobian(M1, Q);
    C1q = 1/2*(j1+j1'-diff(M, Q(1)));
    j2 = jacobian(M2, Q);
    C2q = 1/2*(j2+j2'-diff(M, Q(2)));
    j3 = jacobian(M3, Q);
    C3q = 1/2*(j3+j3'-diff(M, Q(3)));

    dQ_T = dQ';
    c1qdq = simplify(dQ_T'*C1q*dQ_T);
    c2qdq = simplify(dQ_T'*C2q*dQ_T);
    c3qdq = simplify(dQ_T'*C3q*dQ_T);

    cqdq = [c1qdq;
            c2qdq;
            c3qdq];

    offset = sym(zeros(3, N));

    % COM offsets
    offset(:, 1) = r1_1c1;
    offset(:, 2) = r2_2c2;
    offset(:, 3) = r3_3c3;

    % Compute roc
    roc = sym(zeros(3, N));
    for i=1:N-1
        roc(:, i) = compute_roc(oTn, A, offset, i);
    end

    % Compute Gravity Term
    g = [0; 0; -9.81];
    gq = simplify(compute_gravity(Q_s, m, roc, g));
end
