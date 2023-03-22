shader_type canvas_item;
#define u uint //shorthand

uniform u window_radius = u(4);//should never be 0

#define RGB vec3 //type annotation
#define GET_PIXEL(UV) (textureLod(SCREEN_TEXTURE,UV, 0.0))
#define CURRENT_PIXEL (GET_PIXEL(SCREEN_UV))
#define GEN_STARTPOS(qmask,xy) ((float(-qmask.xy)*offset.xy) + SCREEN_UV.xy)
#define GEN_ENDPOS(qmask,xy) ((float(1^qmask.xy)*offset.xy) + SCREEN_UV.xy)

float get_max_val(vec3 inp)
{
	float r = inp[0];
	for(u i=uint(1); i<u(3); i++)
	{
		if(r < inp[i])
		{
			r = inp[i];
		}
	}
	return r;
}

ivec2 generate_q_mask(u q)
{
	return ivec2((int(q)>>0)&1, (int(q)>>1)&1);
}

void fragment() {
	vec2 offset = SCREEN_PIXEL_SIZE *  float(window_radius);
	float no_of_samples = pow(float(window_radius + u(1)) ,2);
	RGB result = vec3 (0.0,0.0,0.0);

	u q2use;  //index of the quater to find average of for final average calculation 
	float val;//used for holding value (V) of HSV of pixel
	float qo; //Standard deviation, o looks kind of like a sigma
	bool firstrun = true;
	ivec2 q_mask;
	vec2 start;
	vec2 end;
	float qat; //quarter average temporary
	float qot; //quarter SD temporary

	for(u qi = u(0); qi <= u(3); qi++)
	{
		q_mask = generate_q_mask(qi);
		start = vec2(GEN_STARTPOS(q_mask,x),GEN_STARTPOS(q_mask,y));
		end = vec2(GEN_ENDPOS(q_mask,x), GEN_ENDPOS(q_mask,y));
		
		qat = 0.0;
		qot = 0.0;
		for(float ix = start.x; ix <= end.x;  ix = ix + SCREEN_PIXEL_SIZE.x)
		{
			for(float iy = start.y; iy <= end.y;  iy = iy + SCREEN_PIXEL_SIZE.y)
			{
				//finding the HSV V
				val = get_max_val(GET_PIXEL(vec2(ix,iy)).rgb);
				qat = qat + val;
				qot  = qot +  pow(val,2);//calculate SD without knowing mean (yet)
			}
		}
		//calculate vairance, should be SD 
		//but doesn't matter as only used to compare mangitudes 
		qot =  sqrt((qot - pow(qat,2)/no_of_samples)/no_of_samples);
		
		if(qot < qo || firstrun == true)
		{
			qo = qot;
			q2use =  qi; //save quadrant with lowest SD
			firstrun = false;
		}
	}
	
	q_mask = generate_q_mask(q2use);
	start = vec2(GEN_STARTPOS(q_mask,x),GEN_STARTPOS(q_mask,y));
	end = vec2(GEN_ENDPOS(q_mask,x), GEN_ENDPOS(q_mask,y));
	
	for(float ix = start.x; ix <= end.x;  ix = ix + SCREEN_PIXEL_SIZE.x)
	{
		for(float iy = start.y; iy <= end.y;  iy = iy + SCREEN_PIXEL_SIZE.y)
		{
			result.rgb = result.rgb + GET_PIXEL(vec2(ix,iy)).rgb;
		}
	}
	
	COLOR.rgb = (result/no_of_samples); 
}
