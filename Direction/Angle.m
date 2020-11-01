% Angle takes the target coordinates and nucleus coordanite as input
% returns the angle between them.
function [theta] = Angle(p1,p2,p3)

a_square = power(p2(1)-p3(1),2)+power(p2(2)-p3(2),2);
b_square = power(p1(1)-p3(1),2)+power(p1(2)-p3(2),2);
c_square = power(p1(1)-p2(1),2)+power(p1(2)-p2(2),2);
costheta = (a_square+c_square-b_square)/(2*sqrt(a_square)*sqrt(c_square));
theta = acos(costheta)*180/pi;

end