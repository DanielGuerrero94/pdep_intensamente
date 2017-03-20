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
    self.eventos_del_dia.push evento
  end

  def asentar(evento)
    self.emocion.asentar evento,self
  end

  def niega?(evento)
    self.emocion.niega? evento
  end

  def convertir_en_central(evento)
    self.pensamientos_centrales.push evento
  end

  def recuerdos_recientes
    self.eventos_del_dia.take(5)
  end

  def recuerdos_dificiles_de_expresar
    self.pensamientos_centrales.select{|pensamiento|
      pensamiento.descripcion.length > 10}
  end

  def descansar
    self.procesos_mentales.each{|proceso|
      proceso.procesar self}
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
      persona.convertir_en_central evento
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
    persona.convertir_en_central evento
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
    persona.eventos_del_dia.each{|evento|
      evento.emocion.asentar(evento,persona)}
  end
end

class Asentamiento_Selectivo
  attr_accessor :palabra

  def initialize(palabra)
    self.palabra = palabra
  end

  def procesar(persona)
    persona.eventos_del_dia
        .select{|evento|
      ! evento.descripcion.include? self.palabra}
        .each{|evento|
      persona.asentar(evento)}
  end
end

class Profundizacion
  def procesar(persona)
      persona.eventos_del_dia
          .select{|evento|
        !persona.pensamientos_centrales.member?(evento) && !persona.niega?(evento)}
          .each{|evento|
        persona.largo_plazo.push evento
      }
    end
end

class Control_Hormonal
  def procesar(persona)
    if desequilibrio_hormonal?(persona)
      self.disminuir_felicidad(persona)
      self.perder_pensamientos(persona)
    end
  end

  def desequilibrio_hormonal?(persona)
    self.central_en_largo_plazo?(persona) || self.emocion_domina?(persona)
  end

  def emocion_domina?(persona)
    primer_emocion = persona.eventos_del_dia.first.emocion
    persona.eventos_del_dia.all?{|evento| evento.emocion == primer_emocion}
  end

  def central_en_largo_plazo?(persona)
    persona.pensamientos_centrales.any?{|evento| persona.largo_plazo.member? evento}
  end

  def disminuir_felicidad(persona)
    persona.felicidad *= 0.75
  end

  def perder_pensamientos(persona)
    #No debe ser la mejor forma de sacar 3, pero no quiero hacer 3 shift ni un for y take solo los retorna
    persona.pensamientos_centrales = persona.pensamientos_centrales.drop(3)
  end
end

class Restauracion_Cognitiva
  #No se tirar exceptions pero quizas deberia
  def procesar(persona)
    if !self.supera_el_maximo? persona
      persona.felicidad += 100
    end
  end

  def supera_el_maximo?(persona)
    persona.felicidad + 100 > 1000
  end
end

class Liberar_Eventos_Del_Dia
  def procesar(persona)
    persona.eventos_del_dia.clear
  end
end