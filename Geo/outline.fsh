


void main(){
    
    const float piOver = 3.14159265358979;
    const float lineTolerance = 1.3;
    float dotProduct = dot(_surface.view, _surface.normal);
    
    if( !((piOver / 2 + lineTolerance) > dotProduct &&
          (piOver / 2 - lineTolerance) < dotProduct ) ){
//        _output.color.rgba = vec4(1.0,1.0,1.0,1.0);
        gl_FragColor = vec4(0.0,1.0,0.0,1.0);
    }
//    gl_FragColor = vec4(0.0,1.0,0.0,1.0);
}