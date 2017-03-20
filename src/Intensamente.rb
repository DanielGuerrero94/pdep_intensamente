require 'singleton'

class Persona
  attr_accessor :felicidad, :emocion, :eventos_del_dia, :pensamientos_centrales, :largo_plazo, :procesos_mentales

  def initialize(emocion=Alegria.instance)
    self.emocion = emocion
    self.felicidad = 1000
    self.eventos_del_dia = []
    self.pensamientos_centrales = []
    self.procesos_mentales = []
    self.largo_plazo = []
  end

  def vivir(evento)
    evento.emocion = self.emocion
    self.eventos_del_dia.push(evento)
  end

  def asentar(evento)
    self.emocion.asentar evento,self
  end

  def niega?(evento)
    self.emocion.niega? evento
  end

  def convertir_en_central(evento)
    self.pensamientos_centrales.push(evento)
  end

  def recuerdos_recientes
    self.eventos_del_dia.take(5)
  end

  def recuerdos_dificiles_de_expresar
    self.pensamientos_centrales.select do |pensamiento|
      pensamiento.descripcion.length > 10
    end
  end

  def descansar
    self.procesos_mentales.each do |proceso|
      proceso.procesar self
    end
  end
end

class Evento
  attr_accessor :descripcion,:fecha,:emocion

  def initialize(descripcion,fecha)
    self.descripcion = descripcion
    self.fecha = fecha
  end
end

#Todas las emociones deberian ser singleton para
#no tener que preguntar por la clase al intentar saber si una emocion niega a la otra

class Emocion

  def asentar(evento,persona)

  end

  def niega?evento
    false
  end
end

class Alegria < Emocion
  include Singleton

  def asentar(evento,persona)
    super evento,persona
    if persona.felicidad > 500
      persona.convertir_en_central(evento)
    end
  end

  def niega?(evento)
    evento.emocion != self
  end
end

class Tristeza < Emocion
  include Singleton

  def asentar(evento,persona)
    super evento,persona
    persona.convertir_en_central(evento)
    persona.felicidad *= 0.9
  end

  def niega?(evento)
    evento.emocion == Alegria.instance
  end
end

class Disgusto < Emocion
  include Singleton
end

class Furia < Emocion
  include Singleton
end

class Terror < Emocion
  include Singleton
end

class Asentamiento
  def procesar(persona)
    persona.eventos_del_dia.each do |evento|
      persona.asentar(evento)
      persona.largo_plazo.push(evento)
    end
  end
end

class Asentamiento_Selectivo
  attr_accessor :palabra

  def initialize(palabra)
    self.palabra = palabra
  end

  def procesar(persona)
    filtered = persona.eventos_del_dia.select do |evento|
      ! evento.descripcion.include? self.palabra
    end

    filtered.each do |evento|
      persona.asentar(evento)
      persona.largo_plazo.push(evento)
    end
  end
end