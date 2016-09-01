function vel = get_velocity(pup,window_size)

x = pup.x;
y = pup.y;
t = pup.t;

distance = 44;
H_res = 800;
V_res = 600;
H_monitor = 44.5;
V_monitor = 25;

smooth_x = smooth(x,'sgolay')';
smooth_y = smooth(y,'sgolay')';

%   - steve's code -- convert from pixels to degrees. confirm 
%     distance / resolution / screensize settings are accurate in
%     Pix2Deg

deg_x = Pix2Deg(smooth_x,distance,H_res,V_res,H_monitor,V_monitor);
deg_y = Pix2Deg(smooth_y,distance,H_res,V_res,H_monitor,V_monitor);

new_size = [size(deg_x,1) size(deg_x,2) - (window_size+1)];

x_vel = zeros(new_size); 
y_vel = zeros(new_size);
new_t = zeros(new_size);

%   - velocity over n sample window

for j = (window_size+1):size(deg_x,2)
    delta_x = deg_x(:,j) - deg_x(:,j-window_size);
    delta_y = deg_y(:,j) - deg_y(:,j-window_size);
    delta_t = t(:,j) - t(:,j-window_size);

    x_vel(:,j-window_size) = abs(delta_x ./ delta_t);
    y_vel(:,j-window_size) = abs(delta_y ./ delta_t);
    new_t(:,j-window_size) = t(:,j);
end

vel.x = x_vel;
vel.y = y_vel;
vel.t = new_t;

