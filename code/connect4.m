function connect4(MCi, val, color, lineW)
% Plot the connection between 4 markers.

    arguments
        % Matrix containig the data of the markers at time i
        MCi (:, :) {}
        % Markers position in MCi
        val (1, 4) double {mustBePositive}
        % (OPTIONAL) Plot color
        color (1, 3) double {mustBeNumeric} = [1, 0, 1]
        % (OPTIONAL) Plot line width
        lineW double {mustBePositive, mustBeFinite} = 2
    end
    
    % collecting positions
    val_X  = [MCi(val(1))  ; MCi(val(2))  ; MCi(val(3))  ; MCi(val(4))  ; MCi(val(1))  ; MCi(val(3))  ; MCi(val(1))  ; MCi(val(2))  ; MCi(val(4))  ];
    val_Y  = [MCi(val(1)+1); MCi(val(2)+1); MCi(val(3)+1); MCi(val(4)+1); MCi(val(1)+1); MCi(val(3)+1); MCi(val(1)+1); MCi(val(2)+1); MCi(val(4)+1)];
    val_Z  = [MCi(val(1)+2); MCi(val(2)+2); MCi(val(3)+2); MCi(val(4)+2); MCi(val(1)+2); MCi(val(3)+2); MCi(val(1)+2); MCi(val(2)+2); MCi(val(4)+2)];

    % plot markers
    plot3(val_X,val_Y,val_Z,'Color',color,'LineWidth',lineW);
end
