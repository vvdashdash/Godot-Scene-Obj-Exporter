
tool
extends Spatial

class_name ExportAsMesh

export var ExportName = "default"
export var ExportPath = ""
export var Activate = false setget Export

func Export(In):
	
	print("Exporting...")
	
	var F = File.new()
	var Export = ExportPath + "/" + ExportName + ".obj"
	
	F.open(Export, File.WRITE)
	F.store_string(MeshData())
	F.close()
	
	print("Exported!")



func MeshData():
	
	var D = GetMeshChildren(self)
	var Based = D.duplicate(true)
	
	for x in range(0,D.size()):
		D[x] = D[x].mesh
	
	var Final = []
	var FinalIndexes = []
	
	var C = 0
	var Biggest = 0
	
	#Per mesh...
	for X in D:
	
		var F = Array(X.get_faces())
		
		var Indexes = RemoveDupesAndGiveIndexes(F, Biggest)
		
		FinalIndexes.append(Indexes[0])
		Biggest = Indexes[1]
		
		#make array of vec3s in to just array, easier to iterate
		for x in F.size():
			F[x] = Based[C].to_global(F[x])
			F[x] = [F[x].x,F[x].y,F[x].z]
		
		#go through all of the numbers and make sure they are string floats with 6 decimal points
		for x in F.size():
			for y in F[x].size():
				F[x][y] = NumToSixFloat(F[x][y])
		
		#get rid of any duplicate verticies
		var Arr = []
		for x in F.size():
			if !Arr.has(F[x]):
				Arr.append(F[x])

		F = Arr
		

		Final.append(F)
		C += 1


	var FinalText = "#\n#Godot export\n#"

	#Per mesh, but with final data...
	for x in Final.size():

		#vertices

		for y in (Final[x].size()):
			
			#per vertex, add line for it
			FinalText += "\nv " + str(Final[x][y][0]) + " " + str(Final[x][y][1]) + " " + str(Final[x][y][2])

		#faces

		for z in (FinalIndexes[x].size()/3):
			z = (z * 3)

			#for every 3 points in face indexes, add line for it
			FinalText += "\nf " + str(FinalIndexes[x][z + 2]) + " " + str(FinalIndexes[x][z + 1]) + " " + str(FinalIndexes[x][z])
			
		
		#smooth off
		FinalText += "\ns off"
		
		
	return(FinalText)


func RemoveDupesAndGiveIndexes(Target, Startingpoint = 0):

	var Dict = {}

	for X in Target:
		if !Dict.has(X):
			Dict[X] = Dict.size() + 1 + Startingpoint

	var Final = []
	
	for X in Target:
		Final.append(Dict[X])
	
	return([Final, Dict.size() + Startingpoint])


func NumToSixFloat(Epic):
	
	var Str = str(Epic)
	if "." in Str:
		#Str = Str.split(".", false, 1)
		#for x in range(0,(6 - len(Str[1]))-1):
		#	NewDec += "0"
		pass
	else:
		Str += ".000000"
	
	return(Str)


func GetMeshChildren(node):
	
	var Results = []

	for x in node.get_children():
		if x is MeshInstance and x.is_visible_in_tree():
			Results.append(x)
		if x.get_child_count() != 0:
			var n = GetMeshChildren(x)
			for y in n:
				Results.append(y)
				
	return(Results)
