// Created by Crowbar 0.71

$modelname "scp_pandemic\deno_ports\scp_173\scp_173.mdl"

$bodygroup "body"
{
	studio "scp_173.smd"
}

$surfaceprop "concrete"

$contents "solid"

$illumposition 0 0 0

$cdmaterials "models\scp_pandemic\deno_ports\scp_173\"

$cbox 0 0 0 0 0 0

$bbox -114.65 -110.894 -36.743 157.324 110.894 36.779

$hboxset "default"

$sequence "idle" {
	"scp_173_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "action1" {
	"scp_173_anims\action1.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "action2" {
	"scp_173_anims\action2.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "action3" {
	"scp_173_anims\action3.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "action4" {
	"scp_173_anims\action4.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "action5" {
	"scp_173_anims\action5.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "action6" {
	"scp_173_anims\action6.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "action7" {
	"scp_173_anims\action7.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "action8" {
	"scp_173_anims\action8.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "action9" {
	"scp_173_anims\action9.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "action10" {
	"scp_173_anims\action10.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "scp_173_physics.smd" {
	$mass 1000
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 16
}
