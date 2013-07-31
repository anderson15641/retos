class CreateArchivos < ActiveRecord::Migration
  def change
    create_table :archivos do |t|
      t.string :nombre
      t.string :nombre_real
      t.text :ubicacion
      t.references :correo, index: true

      t.timestamps
    end
  end
end
