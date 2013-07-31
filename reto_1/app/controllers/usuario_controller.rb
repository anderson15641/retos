class UsuarioController < ApplicationController
	def crear_usuario
	  	@error_nuevo_usuario = false;
	  	if request.post?
  			@Usuario = Usuario.new({
	   			:nombre => params[:nombre],
	   			:apellido => params[:apellido],
	   			:correo => params[:correo],
	   			:contrasena => params[:contrasena]
			});
			@Usuario.save();
			redirect_to :controller => "sesiones", :action => "iniciar_sesion";
	  	end
	end
end
