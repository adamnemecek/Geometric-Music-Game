#version 300 es

uniform mat4 u_viewProjectionTransformMatrix;
in vec4 a_position;
out vec4 outPosition;

void main(){
    outPosition = u_viewProjectionTransformMatrix * a_position;
}