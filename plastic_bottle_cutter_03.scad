// if in project
use <../../../_utils_v2/_round/polyround.scad>
use <../../../_utils_v2/fillet.scad>
use <../../../_utils_v2/m3-m8.scad>
use <../../../_utils_v2/threads.scad>

// if standalone
use <../_utils_v2/_round/polyround.scad>
use <../_utils_v2/fillet.scad>
use <../_utils_v2/m3-m8.scad>
use <../_utils_v2/threads.scad>

m3_cap_diameter = 6.0; 
m3_cap_h = 3;
m3_nut_G = 6.6;
m3_nut_G_inner_diff=0.2;
m3_nut_H = 2.4 + 0.2;
m3_screw_diameter = 3.4+0.2; //M3 screw + diff (prev 0.4)
m3_washer_diameter_diff = 1;
m3_washer_diameter = 7 + m3_washer_diameter_diff; // M3 washer diameter 7mm + diff
m3_washer_thickness = 0.5;
m3_square_nut_S=5.5+0.2;
m3_square_nut_H=1.8+0.2;

m5_cap_h = 4.82+0.18;
m5_screw_diameter_diff = 1;
m5_screw_diameter = 5 + m5_screw_diameter_diff;
m5_washer_diameter_diff = 0.2;
m5_washer_diameter = 10 + m5_washer_diameter_diff;
m5_washer_height = 1;
m5_nut_G = 9;
m5_nut_S = 7.95+0.3; //orig 7.95
m5_nut_H = 4.49 + 0.2;

part="";
print_pads=false;

//outer,inner,height,caps diameter out, xdiff, cap add
bearing6203=[40,17,12,4.4,1.9,1];
bearingR82RS=[28.575,12.7,7.938,2,0.5,0];
bearing696=[15,6,5,2,0.5,0];

bearings=[bearing6203,bearingR82RS,bearing696];
bearing_index=0;
bearing=bearings[bearing_index];

string_height=13;
string_height_req=8;
up_left=string_height<=10.5?7.9:7.9+(string_height-10.5);
bottom=7;

xdiff=bearing[4];
string_width=0.8;
spacer_height=bearing[2]+up_left-1.5;
spacer_height_diff=0.6;

string_height_gr1=7.5;

right_bearing_down=1+0.2;
bearings_inner_diameter_add=[0.1-0.5,0.2-0.5];//!!!!

inner_rays=16;
inner_rays_cut=[1,1.4];

up=[
	 [up_left, bearing[1]+6]
	,[up_left+bearing[2]-right_bearing_down,bearing[1]+8]
];
inner=[
	 [bearing[2]+up[0].x,bearing[1]+bearings_inner_diameter_add[0]]
	,[bearing[2]+up[1].x,bearing[1]+bearings_inner_diameter_add[1]]
];

module nut(G=undef,H,S=undef)
{
    // G,e
	// S,F
    //R = 0.5; A = 0; x = cos(A) * R; y = sin(A) * R;
	
	gg=str(S) != "undef" ? S/cos(30) : G;
	
    nut_points=[
	 [0.5,0]
	,[0.25,0.433013]
	,[-0.25,0.433013]
	,[-0.5,0]
	,[-0.25,-0.433013]
	,[0.25,-0.433013]
    ];

    scale ([gg,gg,1])
    linear_extrude(H)
	polygon (points=nut_points);
}

module proto(main=true, bearings=true, pr=true)
{
	translate([xdiff,0,2])
	{
		if (main)
			color ("red")
			translate ([-20,0,0])
				import ("proto/1o.stl");
		
		if (pr)
			color ("lime")
			translate ([-359,-110,0])
			rotate ([0,0,0])
				import ("proto/2o.stl");
	}
	
	if (bearings)
	{
		index=[-1,1];
		up=[0,bearing[2]-right_bearing_down];
		for (i=[0:1])
			color("blue")
			translate ([(bearing[0]/2-xdiff)*index[i],0,up_left+up[i]])
			{
				if (bearing_index==0)
				{
					translate ([0,0,6])
					rotate ([0,90,0])
						import ("proto/6203.stl");
				}
				else
				{
					difference()
					{
						cylinder (d=bearing[0],h=bearing[2],$fn=60);
						translate ([0,0,-0.1])
							cylinder (d=bearing[1],h=bearing[2]+0.2,$fn=60);
					}
				}
			}
	}
}

module fix(xoffs=0,yoffs=0,pads=false)
{
	for (x=[-1,1])
		translate ([0,x*(bearing[0]/2-4),-bottom-yoffs-0.1])
		{
			cylinder (d=5+xoffs*2,h=bottom+0.2+yoffs,$fn=100);
			if (pads)
				cylinder (d=18,h=0.4,$fn=100);
		}
}


module main(screws=true,fix_enabled=true,height,title=false)
{
	xx=[-1,1];
	nuth=string_height-2;//44444 string_height bottom
	
	union()
	{
		difference()
		{
			union()
			{
				hull()
				for (i=[0:1])
					translate ([(bearing[0]/2-xdiff)*xx[i],0,-bottom+0.01])
						cylinder (d=bearing[0],h=bottom,$fn=100);
				
				for (i=[0:1])
				{					
					translate ([(bearing[0]/2-xdiff)*xx[i],0,0])
						cylinder (d=up[i][1],h=up[i][0],$fn=100);
				}
				
				cut=1;
				angle=360/inner_rays;
				for (i=[0:1])
					translate ([(bearing[0]/2-xdiff)*xx[i],0,0])
					{
						difference()
						{
							union()
							{
								hh=inner[i][0]-cut;
								cylinder (d=inner[i][1],h=hh,$fn=100);
								translate ([0,0,hh-0.01])
									cylinder (d1=inner[i][1],d2=inner[i][1]-cut,h=cut,$fn=100);
							}
							for (a=[0:inner_rays-1])
								rotate ([0,0,angle*a])
								translate ([inner[i][1]/2-inner_rays_cut.x/2,-inner_rays_cut.y/2,-0.01])
									cube ([inner_rays_cut.x,inner_rays_cut.y,inner[i][0]]);
						}
					}			
			}
			
			if (screws)
				for (i=[0:1])
					translate ([(bearing[0]/2-xdiff)*xx[i],0,-bottom-0.01])
					{
						cylinder (d=m5_screw_diameter,h=100,$fn=100);
						nut (m5_nut_G,nuth);
					}
			if (fix_enabled)
				fix();
			
			if (title)
			translate ([0,0,-bottom-0.01])
			translate ([1,0,0])
			mirror([1,0,0])
			{
				linear_extrude(1)
					text(text=str(height),font="Impact:style=Bold",size=8,halign="center",valign="center");
				translate ([0,-5.2,0])
				linear_extrude(1)
					text(text="_",font="Arial:style=Bold",size=12,halign="center",valign="center");
			}
		}
		if (screws)
			for (i=[0:1])
				translate ([(bearing[0]/2-xdiff)*xx[i],0,(nuth-bottom)-0.01])
					cylinder (d=9,h=0.4,$fn=100);
	}
}

module spacer(height,monolith=false,title=true)
{
	height_real=height+spacer_height_diff;
	w=bearing[0]+15;
	diff=0.6;
	ydiff=0.8;
	dd=bearing[0]+diff*2;
	main_x_cut=dd/5;
	difference()
	{
		union()
		{
			translate ([-(bearing[0]/2-xdiff),-w/2,0])
				cube ([bearing[0]-main_x_cut,w,spacer_height]);
			if (!monolith)
				fix(xoffs=-0.4,yoffs=-(bottom-3),pads=print_pads);
		}
		translate ([-(bearing[0]/2-xdiff),0,-0.1])
		{
			cylinder (d=dd,h=bearing[2]+100,$fn=100);
			translate ([-dd/2,-w/2-0.1,0])
				cube ([dd/2+main_x_cut,w+0.2,100]);
		}
		
		if (!monolith)
		translate ([bearing[0]/2-xdiff,0,-0.1])
		{
			cylinder (d=up[1][1]+diff*2,h=100,$fn=100);
			
			//translate ([0,0,up_left+bearing[2]-ydiff-right_bearing_down])
			//			cylinder (d=bearing[0]+diff*2,h=100,$fn=60);
		}
		
		spacer_cut=4;
		translate ([0,0,up_left+bearing[2]-height_real])
		{
			out=20;
			fillet (r=12,steps=16)
			{
				translate ([-string_width/2,-w/2-0.1,0])
					cube ([string_width,w+0.2,100]);		
				translate ([-string_width/2-out,-0.5,0])
					cube ([string_width+out,1,100]);
			}
			
			points=[
				  [-spacer_cut/2,0]
				, [0,0.866*spacer_cut]
				, [spacer_cut/2,0]
			];
			
			translate ([0,-w/2-0.01,0])
			linear_extrude(100)
				polygon(points);
			
			translate ([0,w/2+0.01,0])
			rotate ([0,0,180])
			linear_extrude(100)
				polygon(points);
			
			screw=10;
			offs=4;
			for (y=[-1,1])
				translate ([-screw/2,y*(w/2-offs),-m3_screw_diameter/2+0.2])
				rotate ([0,90,0])
				{
					cylinder (d=m3_screw_diameter,h=screw,$fn=20);
					translate ([0,0,screw-0.01])
					hull()
					{
						if (string_height>string_height_gr1)
							translate ([12,0,0])
								cylinder (d=m3_cap_diameter,h=20,$fn=20);
						cylinder (d=m3_cap_diameter,h=20,$fn=20);
					}
					translate ([0,0,3])
					rotate ([0,180,0])
					hull()
					{
						nut (m3_nut_G,20);
						if (string_height>string_height_gr1)
							translate ([-20,0,0])
						nut (m3_nut_G,20);
					}
				}
		}
		
		if (title)
		{
			txt_in=0.8;
			translate ([-2.8,0,spacer_height-1])
			translate ([0,-w/2+txt_in-0.01,0])
			rotate ([0,-90,0])
			rotate ([90,0,0])
			{
				translate ([0,-10.5,0])
				linear_extrude(txt_in)
					text(text=str(height),font="Impact",size=8,halign="right",valign="center");
			}
		}
	}
}

module caps()
{
	hh=3+bearing[5];
	difference()
	{
		//88888
		cylinder(d=bearing[1]+bearing[3],h=hh,$fn=80);
		translate ([0,0,-0.1])
		{
			cylinder (d=m5_screw_diameter,h=hh+0.2,$fn=100);
		}
	}
}

module nuts()
{
	hh=5+m5_nut_H+1;
	difference()
	{
		dd=15;
		
		rays=16;
		angle=360/rays;
		for (a=[0:rays-1])
			fillet(r=1,steps=8)
			{
				rotate ([0,0,a*angle])
				translate ([dd/2,0,0])
					cylinder(d=2,h=hh,$fn=80);
				cylinder(d=dd,h=hh,$fn=80);
			}
		
		translate ([0,0,-0.1])
		{
			cylinder (d=m5_screw_diameter,h=100,$fn=100);
			translate ([0,0,5])
				nut (m5_nut_G+0.3,100);
		}
	}
}

vice_diff=1;
vice_inner_r=[40,bearing[0]+vice_diff,bottom];
vice_inner=[vice_inner_r.x+0.1,vice_inner_r.y,vice_inner_r.z+0.1];

vice_table=[24,4,20];

vice_outer_diff=[0,[16,16],10];
vice_outer=[vice_inner_r.x+vice_outer_diff.x
		,vice_inner_r.y+vice_outer_diff.y[0]+vice_outer_diff.y[1]
		,vice_inner_r.z+vice_outer_diff.z+vice_table[0]+vice_outer_diff.z+vice_table[1]];

vice_detail_screw=16;
vice_detail_screw_offset=[12,6];
vice_bolt_offset=22;

module vice_bolt(inner=false)
{
	translate ([0,vice_outer.y/2-vice_bolt_offset,-vice_outer.z-2])
	{
		xyscale=inner?1:0.9;
		scale ([xyscale,xyscale,1])
		metric_thread (diameter=26, pitch=6, length=vice_table[1]+20, internal=inner,
        	              angle=30,  leadin=inner?1:1, leadfac=1.4);
		if (!inner)
		{
			translate ([0,0,0.2])
			rotate ([0,180,0])
				cylinder (d=50,h=10,$fn=6);
		}
	}
}

module vice()
{	
	intersection()
	{
		difference()
		{	
			translate ([-vice_outer.x/2,-vice_outer.y/2,-vice_outer.z-0.1])
			{
				rotate ([90,0,90])
				linear_extrude(vice_outer.x)
					polygon(polyRound([
						 [0,0,30]
						,[0,vice_outer.z,2]
						,[vice_outer.y,vice_outer.z,2]
						,[vice_outer.y,0,0]
					],40));
			}
			
			y=-vice_inner.y/2+(vice_outer_diff.y[0]-vice_outer_diff.y[1])/2;
			translate ([-vice_inner.x/2,y,-vice_inner.z])
				cube (vice_inner);
			
			for (tr=[[y,0],[y+vice_inner.y,180]])
			for (xx=[-vice_detail_screw_offset.x,vice_detail_screw_offset.x])
				translate ([xx,tr[0],-vice_detail_screw_offset.y])
				rotate ([0,0,tr[1]])
				{
					translate ([0,-vice_detail_screw+vice_diff+0.5,0])
					{
						rotate([-90,0,0])
							cylinder (d=m5_screw_diameter(),h=vice_detail_screw+4,$fn=80);
						hull()
						for (z=[0,20])
							translate ([0,0.01,z])
							rotate([90,0,0])
								cylinder (d=14,h=40,$fn=80);
					}
					hull()
					for (z=[0,10])
						translate ([0,-4,z])
						rotate([90,0,0])
							nut(G=m5_nut_G+0.2,H=m5_nut_H);
				}
			
			translate ([-vice_outer.x/2-0.1
					,-vice_outer.y/2+vice_table[2]+vice_table[0]/2
					,-vice_inner.z-vice_outer_diff.z-vice_table[0]])
			{
				w=vice_outer.x+0.2;
				cube ([w,vice_outer.y,vice_table[0]]);
				translate ([0,0,vice_table[0]/2])
				rotate ([0,90,0])
					cylinder (d=vice_table[0],h=w,$fn=200);
			}		
			vice_bolt(inner=true);
		}
		translate ([-vice_outer.x/2-0.1
				,-vice_outer.y/2
				,-vice_inner.z-vice_outer_diff.z-vice_table[0]])
		{
			w=vice_outer.x+0.2;
			ww=20;
			translate ([0,0,-vice_table[0]])
			{
				cut=20;
				dim=[w,vice_outer.y,vice_table[0]];
				linear_extrude(dim.z+1)
				polygon(polyRound([
					 [0,0,0]
					,[dim.x,0,0]
					,[dim.x,dim.y,cut]
					,[0,dim.y,cut]
				],20));
			}
			translate([0,0,1])
			cube ([w,vice_outer.y,60]);
		}
	}	
}

if (part=="")
{
//	proto(main=false, bearings=true, pr=true);
//	main(height=string_height);
//	spacer(height=string_height);
	spacer(height=7.5);
//	spacer(height=13);
//	caps();
//	nuts();
//	vice();
//	vice_bolt();
}
if (part=="main")
{
	main(height=string_height);
}
if (part=="spacer")
{
	rotate ([180,0,0])
	spacer(height=string_height_req);
}
if (part=="main_spacer")
{
	union()
	{
		main(fix_enabled=false,height=string_height,title=true);
		spacer(height=string_height,monolith=true,title=false);
	}
}
if (part=="caps")
{
	caps();
}
if (part=="nuts")
{
	nuts();
}
if (part=="vice_bolt")
{
	vice_bolt();
}
if (part=="vice")
{
	rotate([0,-90,0])
		vice();
}
