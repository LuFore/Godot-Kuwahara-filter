shader_type canvas_item;


uniform uint window_radius = uint(4);

float get_max_val(vec3 inp)
{
 float r = inp[0];
 for(uint i=uint(1); i<uint(3); i++)
 {
  if(r < inp[i])
  {
   r = inp[i];
  }
 }
 return r;
}

ivec2 generate_q_mask(uint q)
{
 return ivec2((int(q)>>0)&1, (int(q)>>1)&1);
}

void fragment() {
 vec2 offset = SCREEN_PIXEL_SIZE * float(window_radius);
 float no_of_samples = pow(float(window_radius + uint(1)) ,2);
 vec3 result = vec3 (0.0,0.0,0.0);

 uint q2use;
 float val;
 float qo;
 bool firstrun = true;
 ivec2 q_mask;
 vec2 start;
 vec2 end;
 float qat;
 float qot;

 for(uint qi = uint(0); qi <= uint(3); qi++)
 {
  q_mask = generate_q_mask(qi);
  start = vec2(((float(-q_mask.x)*offset.x) + SCREEN_UV.x),((float(-q_mask.y)*offset.y) + SCREEN_UV.y));
  end = vec2(((float(1^q_mask.x)*offset.x) + SCREEN_UV.x), ((float(1^q_mask.y)*offset.y) + SCREEN_UV.y));

  qat = 0.0;
  qot = 0.0;
  for(float ix = start.x; ix <= end.x; ix = ix + SCREEN_PIXEL_SIZE.x)
  {
   for(float iy = start.y; iy <= end.y; iy = iy + SCREEN_PIXEL_SIZE.y)
   {


    val = get_max_val((textureLod(SCREEN_TEXTURE,vec2(ix,iy), 0.0)).rgb);
    qat = qat + val;
    qot = qot + pow(val,2);
   }
  }


  qot = sqrt((qot - pow(qat,2)/no_of_samples)/no_of_samples);



  if(qot < qo || firstrun == true)
  {
   qo = qot;
   q2use = qi;
   firstrun = false;
  }
 }

 q_mask = generate_q_mask(q2use);
 start = vec2(((float(-q_mask.x)*offset.x) + SCREEN_UV.x),((float(-q_mask.y)*offset.y) + SCREEN_UV.y));
 end = vec2(((float(1^q_mask.x)*offset.x) + SCREEN_UV.x), ((float(1^q_mask.y)*offset.y) + SCREEN_UV.y));

 for(float ix = start.x; ix <= end.x; ix = ix + SCREEN_PIXEL_SIZE.x)
 {
  for(float iy = start.y; iy <= end.y; iy = iy + SCREEN_PIXEL_SIZE.y)
  {
   result.rgb = result.rgb + (textureLod(SCREEN_TEXTURE,vec2(ix,iy), 0.0)).rgb;
  }
 }

 COLOR.rgb = (result/no_of_samples);
}
