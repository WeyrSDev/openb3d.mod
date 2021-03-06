
Rem
bbdoc: Shader methods
about: Used for reporting errors.
End Rem
Type TGLShader ' by AdamStrange

	Field ProgramObject:Int
	Field Error:Int
	Field ErrorShader:Int
	Field ErrorLine:Int
	Field ErrorMessage:String	
	
	'shader error types
	Const SHERROR_NONE:Int = - 1
	Const SHERROR_VERTEX:Int = 0
	Const SHERROR_FRAGMENT:Int = 1
	Const SHERROR_LINK:Int = 2
	Const SHERROR_VARIABLE:Int = 3
	
	Method Load:TGLShader(VertexPath:String, FragmentPath:String)
		ProgramObject = -1
		Error = False
		ErrorShader = SHERROR_NONE
		ErrorLine = SHERROR_NONE
		ErrorMessage = ""	
		
		Local VertexCode:String, FragmentCode:String
		
		Try
			Print "Loading vertex file "+ vertexpath
			VertexCode   = LoadText(VertexPath)
			Print "Loading fragment file "+fragmentpath
			FragmentCode = LoadText(FragmentPath)
		Catch Dummy:Object
			Return Null
		EndTry
		
'		Print " Compiling "+VertexPath+" & "+FragmentPath
		Compile(VertexCode, FragmentCode)
		
		Return Self
	End Method
	
	Method Compile:TGLShader(VertexCode:String, FragmentCode:String)
'		Print "Creating program object"
'		If Not ProgramObject Or ProgramObject < 0 Then ProgramObject = glCreateProgramObjectARB()
		If Not ProgramObject Or ProgramObject < 0 Then
			Print " compile Create ProgramObject"
			glewInit() 'must be done AFTER window creation
			ProgramObject = glCreateProgramObjectARB()
		End If	
		
		Local VertexShader  :Int = glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB)
		Local FragmentShader:Int = glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB)
		
		Print "loading vertex..."
		_LoadShader(VertexCode, VertexShader)
		Print "compiling vertex..."
		glCompileShaderARB(VertexShader)
		
		If _CheckForErrors(VertexShader, ErrorMessage) Then
			glDeleteObjectARB(VertexShader)
			
			Error = True
			ErrorShader = SHERROR_VERTEX
			Return Null
			Throw ErrorMessage
		EndIf
		
		Print "loading fragment..."
		_LoadShader(FragmentCode, FragmentShader)
		Print "compiling fragment..."
		glCompileShaderARB(FragmentShader)
		
		If _CheckForErrors(FragmentShader, ErrorMessage) Then
			glDeleteObjectARB(VertexShader)
			glDeleteObjectARB(FragmentShader)

			Error = True
			ErrorShader = SHERROR_FRAGMENT
			
			Return Null
			Throw ErrorMessage
		EndIf
		
		glAttachObjectARB(ProgramObject, VertexShader)
		glAttachObjectARB(ProgramObject, FragmentShader)
		
		glDeleteObjectARB(VertexShader)
		glDeleteObjectARB(FragmentShader)
		
		Error = False
		Print "compile ok"
		Return Self
	End Method
	
	Method link:TGLShader()	
		If Not ProgramObject Or ProgramObject < 0 Then
			Print " link Create ProgramObject"
			glewInit() 'must be done AFTER window creation
			ProgramObject = glCreateProgramObjectARB()
		End If	
		
		Print "  Linking… Program="+ProgramObject
		
		glLinkProgramARB(ProgramObject)
		Print "link 2"
		If _CheckForLinkErrors(ProgramObject, ErrorMessage, False) Then

			Print "link 3"
			Error = True
			ErrorShader = SHERROR_LINK

			Return Null
			Throw ErrorMessage
		End If	
		
		Error = False
		Print " Shader linked OK"
		Return Self
	End Method

	Method ErrorReport()
		Select ErrorShader
			Case SHERROR_VERTEX
				Print "Error in vertex shader. Line " + ErrorLine
			Case SHERROR_FRAGMENT
				Print "Error in fragment shader. Line " + ErrorLine
			Case SHERROR_LINK
				Print "Error in linking vertex and fragment shaders. Line " + errorLine
		End Select		
		Print " - "+ErrorMessage
'		End
	End Method
	
	Method Enable()
'		Print "ProgramObject="+ProgramObject
		glUseProgramObjectARB(ProgramObject)
	End Method
	
	Method Disable()
		glUseProgramObjectARB(0)
	End Method
	
	Method GetUniformLocation:Int(Name:String)
		Return glGetUniformLocationARB(ProgramObject, Name)
	End Method
	
	Method Delete()
		glDeleteObjectARB(ProgramObject)
	End Method
	
	Method setUniformFloatArray1:Int(name:String, count:Int, val:Float Ptr)
		Local loc:Int = glGetUniformLocationARB(ProgramObject, name.ToCString())

		If loc < 0 Then
			Error = True
			ErrorShader = SHERROR_VARIABLE
			ErrorMessage = "Problem Setting Uniform Float Array Var '"+name+"'"
			Return False
		End If

		glUniform1fv(loc, count, val)
		
		Return True
	End Method
	
	Method setUniformMatrix4:Int(name:String, count:Int, transpose:Int, mat:Float Ptr)
		Local loc:Int = glGetUniformLocationARB(ProgramObject, name.ToCString())

		If loc < 0 Then
			Error = True
			ErrorShader = SHERROR_VARIABLE
			ErrorMessage = "Problem Setting Uniform Float Array Var '"+name+"'"
			Return False
		End If

		glUniformMatrix4fv(loc, count, transpose, mat)
		
		Return True
	End Method
	
	Method setUniformFloat1:Int(name:String, val:Float)
		Local loc:Int = glGetUniformLocationARB(ProgramObject, name.ToCString())

		If loc < 0 Then
			Error = True
			ErrorShader = SHERROR_VARIABLE
			ErrorMessage = "Problem Setting Uniform Var '"+name+"'"
			Return False
		End If

		glUniform1fARB(loc, val)
		
		Return True
	End Method
	
	Method setUniformFloat2:Int(name:String, val1:Float, val2:Float)
		Local loc:Int = glGetUniformLocationARB(ProgramObject, name.ToCString())

		If loc < 0 Then
			Error = True
			ErrorShader = SHERROR_VARIABLE
			ErrorMessage = "Problem Setting Uniform Var '"+name+"'"
			Return False
		End If

		glUniform2fARB(loc, val1, val2)
		
		Return True
	End Method
	
	Method setUniformFloat3:Int(name:String, val1:Float, val2:Float, val3:Float)
		Local loc:Int = glGetUniformLocationARB(ProgramObject, name.ToCString())

		If loc < 0 Then
			Error = True
			ErrorShader = SHERROR_VARIABLE
			ErrorMessage = "Problem Setting Uniform Var '"+name+"'"
			Return False
		End If

		glUniform3fARB(loc, val1, val2, val3)
		
		Return True
	End Method
	
	Method setUniformFloat4:Int(name:String, val1:Float, val2:Float, val3:Float, val4:Float)
		Local loc:Int = glGetUniformLocationARB(ProgramObject, name.ToCString())

		If loc < 0 Then
			Error = True
			ErrorShader = SHERROR_VARIABLE
			ErrorMessage = "Problem Setting Uniform Var '"+name+"'"
			Return False
		End If

		glUniform4fARB(loc, val1, val2, val3, val4)
		
		Return True
	End Method
	
	' Set Uniform Variable Integer(s)
	Method setUniformInt1:Int(name:String, val:Int)
		Local loc:Int = glGetUniformLocationARB(ProgramObject, name.ToCString())

		If loc < 0 Then
			Error = True
			ErrorShader = SHERROR_VARIABLE
			ErrorMessage = "Problem Setting Uniform (int) Var '"+name+"'"
			Return False
		End If

		glUniform1iARB(loc, val)

		Return True
	End Method
	
	Method setUniformInt2:Int(name:String, val1:Int, val2:Int)
		Local loc:Int = glGetUniformLocationARB(ProgramObject, name.ToCString())

		If loc < 0 Then
			Error = True
			ErrorShader = SHERROR_VARIABLE
			ErrorMessage = "Problem Setting Uniform (int) Var '"+name+"'"
			Return False
		End If

		glUniform2iARB(loc, val1, val2)
		
		Return True
	End Method
	
	Method setUniformInt3:Int(name:String, val1:Int, val2:Int, val3:Int)
		Local loc:Int = glGetUniformLocationARB(ProgramObject, name.ToCString())

		If loc < 0 Then
			Error = True
			ErrorShader = SHERROR_VARIABLE
			ErrorMessage = "Problem Setting Uniform (int) Var '"+name+"'"
			Return False
		End If

		glUniform3iARB(loc, val1, val2, val3)
		
		Return True
	End Method
	
	Method setUniformInt4:Int(name:String, val1:Int, val2:Int, val3:Int, val4:Int)
		Local loc:Int = glGetUniformLocationARB(ProgramObject, name.ToCString())

		If loc < 0 Then
			Error = True
			ErrorShader = SHERROR_VARIABLE
			ErrorMessage = "Problem Setting Uniform (int) Var '"+name+"'"
			Return False
		End If

		glUniform4iARB(loc, val1, val2, val3, val4)
		
		Return True
	End Method
	
	Function _LoadShader(ShaderCode:String, ShaderObject:Int)
		Local ShaderCodeC:Byte Ptr = ShaderCode.ToCString()
		Local ShaderCodeLen:Int    = ShaderCode.Length
		
		glShaderSourceARB(ShaderObject, 1, Varptr ShaderCodeC, Varptr ShaderCodeLen)
		
		MemFree(ShaderCodeC)
	End Function
	
	Method _CheckForErrors:Int(ShaderObject:Int, ErrorString:String Var, Compiled:Int = True)
		Local Successful:Int
		
		If Compiled Then
			glGetShaderiv (ShaderObject, GL_COMPILE_STATUS, Varptr Successful)
		Else
			glGetProgramiv(ShaderObject, GL_LINK_STATUS,    Varptr Successful)
		EndIf
		
		If Not Successful Then
			Local ErrorLength:Int
			glGetObjectParameterivARB(ShaderObject, GL_OBJECT_INFO_LOG_LENGTH_ARB, Varptr ErrorLength)
			
			Local Message:Byte Ptr = MemAlloc(ErrorLength), Dummy:Int
			
			glGetInfoLogARB(ShaderObject, ErrorLength, Varptr Dummy, Message)
			
			ErrorString = String.FromCString(Message)
			MemFree(Message)

			'strip the "ERROR: 0:" from the beginning
			ErrorString = Right(ErrorString, ErrorString.length - 9)
			
			'get the line number
			Local pos:Int = Instr(ErrorString, ":", 1)
			Local Line:String = Left(ErrorString, pos - 1)
			ErrorLine = Line.toint()
			
			'strip the errorline
			ErrorString = Right(ErrorString, ErrorString.length-pos-1)
			
			Return -1
		EndIf
		
		Return 0
	End Method
	
	Method _CheckForLinkErrors:Int(ShaderObject:Int, ErrorString:String Var, Compiled:Int = True)
		Local Successful:Int
		
		If Compiled Then
			glGetShaderiv (ShaderObject, GL_COMPILE_STATUS, Varptr Successful)
		Else
			glGetProgramiv(ShaderObject, GL_LINK_STATUS,    Varptr Successful)
		EndIf
		
		If Not Successful Then
'			Return -1
			Local ErrorLength:Int
			glGetObjectParameterivARB(ShaderObject, GL_OBJECT_INFO_LOG_LENGTH_ARB, Varptr ErrorLength)
			
			Local Message:Byte Ptr = MemAlloc(ErrorLength), Dummy:Int
			
			glGetProgramInfoLog(ShaderObject, ErrorLength, Varptr Dummy, Message);
'			glGetInfoLogARB(ShaderObject, ErrorLength, Varptr Dummy, Message)
			
			ErrorString = String.FromCString(Message)
			MemFree(Message)

			'strip the "ERROR: 0:" from the beginning
			ErrorString = Right(ErrorString, ErrorString.length - 9)
			
			'get the line number
			Local pos:Int = Instr(ErrorString, ":", 1)
			Local Line:String = Left(ErrorString, pos - 1)
			ErrorLine = Line.toint()
			
			'strip the errorline
			ErrorString = Right(ErrorString, ErrorString.length-pos-1)
			
			Return -1
		EndIf
		
		Return 0
	End Method
	
	Function CheckCompability:Int()
		Local Extensions:String = String.FromCString(Byte Ptr glGetString(GL_EXTENSIONS))
		Local GLVersion:String  = String.FromCString(Byte Ptr glGetString(GL_VERSION))
		Local GLVersionInt:Int  = GLVersion[.. 3].Replace(".", "").ToInt()
		
		If Extensions.Find("GL_ARB_shader_objects" ) >= 0 And ..
		   Extensions.Find("GL_ARB_vertex_shader"  ) >= 0 And ..
		   Extensions.Find("GL_ARB_fragment_shader") >= 0 Or GLVersionInt >= 20 Then Return True
		
		Return False
	End Function
	
	Method InitShaders:Int(vertShader:String, fragShader:String)
		Local ok:Int = True
		'this is the deferred renderer
		Self.Load(vertShader, fragShader)
		If Self.Error Then
			Self.ErrorReport()
			ok = False
		End If
		Self.Link()
		If Self.Error Then
			Self.ErrorReport()
			ok = False
		End If
		
		Return ok
	End Method
	
End Type
