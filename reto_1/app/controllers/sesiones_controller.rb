class SesionesController < ApplicationController

  def iniciar_sesion
   @error_login = false;
   sesion = get_login();
   if sesion
      redirect_to :controller => "archivos", :action => "listar_archivos";
   end 
   #Verifica si se ha enviado el formulario.
   if request.post?
      #Verifica si el nombre de usuario y la contraseña son correctos.
      if login(params[:correo], params[:contrasena])
         #Los datos son correctos así que redirecciona a la página de bienvenida.
         redirect_to :controller => "sesiones", :action => "bienvenida";
      else
         #Los datos son incorrectos así que setea la variable @error_login a true para mostrar el error por pantalla.
         @error_login = true;
      end
   end
  end

  def cerrar_sesion
   @sesion = get_login();
   if @sesion
      logout();
   else
      redirect_to :controller => "sesiones", :action => "iniciar_sesion";
   end
  end

  def bienvenida
   @sesion = get_login();
   if @sesion
      @nombre = @sesion[:nombre];
      @apellido = @sesion[:apellido];
   else
      redirect_to :controller => "sesiones", :action => "iniciar_sesion";
   end
 end

  #Métodos privados.
   private

   def login(correo, contrasena)
      usuario = Usuario.find_by correo: correo;
      if usuario != nil
         contra = usuario.contrasena
         if contra == contrasena 
            session[:logueado] = true;
            session[:nombre] = usuario.nombre;
            session[:apellido] = usuario.apellido;
            session[:correo] = correo;
            return true;
         end
      end
      return false;
   end
   
   def logout
      #Desloguea al usuario.
      session[:logueado] = false;
      session[:nombre] = nil;
      session[:apellido] = nil;
      session[:correo] = nil;
   end

   def get_login
      #Verifica si el usuario está logueado. Primero pregunta si existe la session[:logueado] y además que este sea true, si existe devuelve la sesión sino existe devuelve false.
      if defined?(session[:logueado]) and session[:logueado]
         #Está logueado.
         return session;
      else
         #No está logueado.
         return false;
      end
   end

end
