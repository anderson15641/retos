class ArchivosController < ApplicationController

 Ruta_archivo_comentarios = "public/comentarios/comentarios.txt";
 Ruta_directorio_archivos = "public/archivos/";
 Extenciones_validas = [".jpg", ".gif", ".bmp", ".png"];

 def subir_archivos
    @formato_erroneo = false;
    sesion = get_login();
      if sesion
        if request.post?
           #Archivo subido por el usuario.
           archivo = params[:archivo];
           #Nombre original del archivo.
           nombre_real = archivo.original_filename;
           #Directorio donde se va a guardar.
           directorio = Ruta_directorio_archivos;
           #ExtensiÃ³n del archivo.
           extension = nombre_real.slice(nombre_real.rindex("."), nombre_real.length).downcase;
           #Verifica que el archivo tenga una extensiÃ³n correcta.
           if Extenciones_validas.include?(extension)
              nombre = get_md5_nombre(nombre_real);
              #Ruta del archivo.
              path = File.join(directorio, nombre);
              #Crear en el archivo en el directorio. Guardamos el resultado en una variable, serÃ¡ true si el archivo se ha guardado correctamente.
              resultado = File.open(path, "wb") { |f| f.write(archivo.read) };
              #Verifica si el archi vo se subiÃ³ correctamente.
              correo = get_correo();
              usuario = Usuario.find_by correo: correo;
              archivo = Archivo.new({
                :nombre => nombre,
                :nombre_real => nombre_real,
                :ubicacion => directorio,
                :usuario => usuario
                });
              archivo.save();
              if resultado
                 subir_archivo = "ok";
              else
                 subir_archivo = "error";
              end
              #Redirige al controlador "archivos", a la acciÃ³n "lista_archivos" y con la variable de tipo GET "subir_archivos" con el valor "ok" si se subiÃ³ el archivo y "error" si no se pudo.
              redirect_to :controller => "archivos", :action => "listar_archivos", :subir_archivo => subir_archivo;
           else
              @formato_erroneo = true;
           end
        end
      else
        redirect_to :controller => "sesiones", :action => "iniciar_sesion";
      end
 end

 def listar_archivos
    #Mensaje que mostrará si la página viene desde otra acción.
    @mensaje = "";
    #Verificamos si existe la variable subir_archivo por GET.
    if params[:subir_archivo].present?
       if params[:subir_archivo] == "ok";
          @mensaje = "El archivo ha sido subido exitosamente.";
       else
          @mensaje = "El archivo no ha podido ser subido.";
       end
    end
    #Verificamos si existe la variable eliminar_archivo por GET.
    if params[:eliminar_archivo].present?
       if params[:eliminar_archivo] == "ok";
          @mensaje = "El archivo ha sido eliminado exitosamente";
       else
          @mensaje = "El archivo no ha podido ser eliminado, ya no es existe o no es suyo.";
       end
    end
    #verifica si esta disponible la opcion borrar imagen
    #Habilitado borrar imagenes
    @usuario_borrar = false;
    if get_login()
      @usuario_borrar = true;
    end
    #Verifica si existe el archivo de los comentarios.
    if File.exist?(Ruta_archivo_comentarios)
       @comentarios = File.read(Ruta_archivo_comentarios);
    else
       @comentarios = "";
    end
    @orden="";
    if params[:orden].present?
      @orden = params[:orden];      
    end  
    @arr_archivos = get_arr_archivos(@orden);
 end

 def borrar_archivos
    sesion = get_login();
    if sesion
      archivo = Archivo.find(params[:archivo]);
      #Guardamos la ruta del archivo a eliminar.
      ruta_al_archivo = archivo.ubicacion.to_s + archivo.nombre.to_s;
      #Verificamos que el archivo exista para eliminarlo.
      if File.exist?(ruta_al_archivo)
         #Si el archivo existe se intentarÃ¡ eliminarlo. Dentro de la variable resultado se guardarÃ¡ true si se pudo eliminar y false si no.
         correo = get_correo();
         correo2 = archivo.usuario.correo;
         if correo.eql?(correo2)  
            archivo.destroy();
            resultado = File.delete(ruta_al_archivo);
          end
      else
         #El archivo no existe asÃ­ que no se pudo eliminar nada.
         resultado = false;
      end
      #Verifica si el archivo se eliminÃ³ correctamente.
      if resultado
         eliminar_archivo = "ok";
      else
         eliminar_archivo = "error";
      end
      redirect_to :controller => "archivos", :action => "listar_archivos", :eliminar_archivo => eliminar_archivo;
    end
 end
 
 def guardar_comentarios
    #Si llega por post intentarÃ¡ guardar los comentarios que ha ingresado el usuario.
    if request.post?
       #Guarda los comentarios en una variable
       comentarios = params[:comentarios];
       #Abre el archivo de comentarios, Si no existe lo crea, si existe lo sobrescribe
       File.open(Ruta_archivo_comentarios, "wb"){
          #Alias
          |f|;
          #Escribe el contenido del archivo.
          f.write(comentarios);
          #Lo cierra para liberar memoria.
          f.close();
       };
    end
    #Verifica si existe el archivo de los comentarios.
    if File.exist?(Ruta_archivo_comentarios)
       #Guarda el contenido del archivo de los comentarios.
       @comentarios = File.read(Ruta_archivo_comentarios);
    else
       #No existe el archivo de los comentarios asÃ­ que guarda comillas vacÃ­as en los comentarios.
       @comentarios = "";
    end
 end

 private 

  def get_arr_archivos(orden)
    if orden == 'usuario' 
      arr_archivos = Archivo.find(:all).sort_by{|c| [c.usuario] }; 
    elsif orden == 'nombre'
      arr_archivos = Archivo.find(:all).sort_by{|c| [c.nombre_real] };
    elsif orden == 'url'
     arr_archivos = Archivo.find(:all).sort_by{|c| [c.usuario] };
    else
      arr_archivos = Archivo.find(:all).sort_by{|c| [c.id] };
    end
    return arr_archivos;
  end

  def get_md5_nombre (nombre)
    time = Time.new;
    return Digest::MD5.hexdigest(nombre + time.inspect);
  end

  def get_login
      #Verifica si el usuario estÃ¡ logueado. Primero pregunta si existe la session[:logueado] y ademÃ¡s que este sea true, si existe devuelve la sesiÃ³n sino existe devuelve false.
      if defined?(session[:logueado]) and session[:logueado]
         #EstÃ¡ logueado.
         return session;
      else
         #No estÃ¡ logueado.
         return false;
      end
  end

  def get_correo
      #Verifica si el usuario estÃ¡ logueado. Primero pregunta si existe la session[:logueado] y ademÃ¡s que este sea true, si existe devuelve la sesiÃ³n sino existe devuelve false.
      if defined?(session[:logueado]) and session[:logueado]
         #EstÃ¡ logueado.
         return session[:correo];
      else
         #No estÃ¡ logueado.
         return nil;
      end
  end
end