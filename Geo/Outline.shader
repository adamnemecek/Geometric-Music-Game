//const float piOver = 3.14159265358979;
//const float lineTolerance = 1.5;

//float dotProduct = dot(_surface.view, _surface.normal);


//if( !( ((piOver / 2.0) + lineTolerance) > dotProduct &&
//      ((piOver / 2.0) - lineTolerance) < dotProduct ) ){
//       _output.color.rgba = vec4(1.0,1.0,1.0,1.0);
//}else{
//       _output.color.rgba = vec4(1.0,0.0,0.0,1.0);
//}


//const float PIover2 = (3.14159265358979 / 2.0);
//const float lineTolerance = 1.5;

//float dotProduct = dot(_surface.view, _surface.normal);

//if ( (PIover2 + lineTolerance) > dotProduct && dotProduct > (PIover2 - lineTolerance) ) {
//    _output.color.rgba = vec4(1.0, 1.0, 1.0, 1.0);
//}else{
//    _output.color.rgba = vec4(0.0, 0.0, 0.0, 0.0);
//}


//_output.color.a = mix(_output.color.a, (0.8 - dot(_surface.view, _surface.normal)) * _output.color.a, 1.0);

//_output.color.rgb = vec3(1.0) - _output.color.rgb;



//_output.color.bg = mix(_output.color.bg, (1.0 - dot(_surface.view, _surface.normal)) * _output.color.bg, 1.0);


_output.color.a = mix(_output.color.a, (0.8 - dot(_surface.view, _surface.normal)) * _output.color.a, 1.0);

