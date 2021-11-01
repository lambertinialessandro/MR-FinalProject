function drawBody(m_column, body, colors, lineW)
% Plot one instance of the body.

    arguments
        % Matrix containig the data of the markers at time i
        m_column (:, :) {}
        % Body struct
        body (1, :) struct
        % (OPTIONAL) Plot color array
        colors (4, 3) double {mustBeNumeric} = [[1, 0, 1]; [1, 0, 1]; [1, 0, 1]; [1, 0, 1]]
        % (OPTIONAL) Plot line width
        lineW double {mustBePositive, mustBeFinite} = 2
    end
    
    % torso
    connect4(m_column, body.torso, colors(1, :), lineW);
    connect4(m_column, body.pelvis, colors(2, :), lineW);

    % left leg
    connect3(m_column, body.l_knee, colors(3, :), lineW);
    connect3(m_column, body.l_calf, colors(3, :), lineW);
    connect3(m_column, body.l_quad, colors(3, :), lineW);
    connect3(m_column, body.l_amstring, colors(3, :), lineW);

    % right leg
    connect3(m_column, body.r_knee, colors(4, :), lineW);
    connect3(m_column, body.r_calf, colors(4, :), lineW);
    connect3(m_column, body.r_quad, colors(4, :), lineW);
    connect3(m_column, body.r_amstring, colors(4, :), lineW);

    % left foot
    connect3(m_column, body.l_foot_P, colors(3, :), lineW);
    connect3(m_column, body.l_foot_A, colors(3, :), lineW);
    connect2(m_column, body.l_foot_c1, colors(3, :), lineW);
    connect2(m_column, body.l_foot_c2, colors(3, :), lineW);

    % right foot
    connect3(m_column, body.r_foot_P, colors(4, :), lineW);
    connect3(m_column, body.r_foot_A, colors(4, :), lineW);
    connect2(m_column, body.r_foot_c1, colors(4, :), lineW);
    connect2(m_column, body.r_foot_c2, colors(4, :), lineW);
end