require 'rspec'
require_relative '../src/Intensamente'

describe 'Test intensamente' do

  let(:riley){
    Persona.new
  }

  let(:evento_1){
    Evento.new 'descripcion','2016-06-01'
  }

  let(:evento_2){
    Evento.new 'otra_descripcion','2016-06-02'
  }

  let(:evento_3){
    Evento.new 'corto','2016-06-02'
  }

  let(:asentamiento){
    Asentamiento.new
  }

  let(:asentamiento_selectivo){
    Asentamiento_Selectivo.new 'corto'
  }

  let(:emocion_compuesta){
    Emocion_Compuesta.new
  }

  it 'deberia asentar alegria' do
    expect(riley.eventos_del_dia.length).to eq(0)
    riley.vivir(evento_1)
    expect(riley.eventos_del_dia.length).to eq(1)
    expect(riley.pensamientos_centrales.length).to eq(0)
    expect(riley.felicidad).to eq(1000)
    riley.asentar(evento_1)
    expect(riley.pensamientos_centrales.length).to eq(1)
  end

  it 'deberia asentar tristeza' do
    tristeza = Tristeza.instance
    riley.emocion = tristeza
    riley.vivir(evento_2)
    riley.asentar(evento_2)
    expect(riley.felicidad).to eq(900)
    expect(riley.pensamientos_centrales.shift).to eq(evento_2)
    expect(evento_2.emocion).to eq(tristeza)
  end

  it 'deberia encontrar recuerdos recientes y dificiles de expresar' do
    riley.vivir evento_1
    riley.vivir evento_2
    riley.vivir evento_3
    expect(riley.recuerdos_recientes.length).to eq(3)
    riley.asentar evento_1
    riley.asentar evento_2
    riley.asentar evento_3
    expect(riley.recuerdos_dificiles_de_expresar.length).to eq(2)
  end

  it 'deberia negar evento porque esta feliz y es un recuerdo disgustoso
      y tambien deberia negar evento porque esta triste y es un evento alegre' do
    riley.emocion = Disgusto.instance
    riley.vivir evento_1
    riley.emocion = Alegria.instance
    expect(riley.niega? evento_1).to eq(true)
    riley.vivir evento_2
    riley.emocion = Tristeza.instance
    expect(riley.niega? evento_1).to eq(false)
    expect(riley.niega? evento_2).to eq(true)
  end

  it 'deberia asentar todos' do
    riley.vivir evento_1
    riley.vivir evento_2
    riley.vivir evento_3
    riley.procesos_mentales.push asentamiento
    expect(riley.pensamientos_centrales.length).to eq(0)
    riley.descansar
    expect(riley.pensamientos_centrales.length).to eq(3)
  end

  it 'deberia asentar todos menos uno' do
    riley.vivir evento_1
    riley.vivir evento_2
    riley.vivir evento_3
    riley.procesos_mentales.push asentamiento_selectivo
    expect(riley.pensamientos_centrales.length).to eq(0)
    riley.descansar
    expect(riley.pensamientos_centrales.length).to eq(2)
  end

  it 'deberia tener en recuerdos de largo plazo todo menos el evento_1' do
    riley.vivir evento_1
    riley.asentar evento_1
    expect(riley.pensamientos_centrales.length).to eq(1)
    riley.felicidad = 10
    riley.vivir evento_2
    riley.vivir evento_3
    riley.asentar evento_2
    riley.asentar evento_3
    #Tiene que seguir estando solo el evento 1
    expect(riley.pensamientos_centrales.length).to eq(1)
    riley.procesos_mentales.push Profundizacion.new
    expect(riley.largo_plazo.length).to eq(0)
    riley.descansar
    expect(riley.largo_plazo.length).to eq(2)
  end

  it 'deberia tener la misma emocion dominante' do
    riley.vivir evento_1
    riley.vivir evento_2
    riley.vivir evento_3
    riley.procesos_mentales.push Asentamiento.new
    riley.procesos_mentales.push Control_Hormonal.new
    riley.descansar
    control = Control_Hormonal.new
    expect(control.desequilibrio_hormonal?(riley)).to eq(true)
    expect(riley.pensamientos_centrales.length).to eq(0)
    expect(riley.felicidad).to eq(750)
  end

  it 'deberia haber un pensamiento central en largo plazo' do
    riley.vivir evento_1
    riley.vivir evento_2
    riley.emocion = Furia.instance
    riley.vivir evento_3
    riley.procesos_mentales.push Asentamiento.new
    riley.procesos_mentales.push Control_Hormonal.new
    riley.largo_plazo.push evento_1
    riley.descansar
    expect(riley.pensamientos_centrales.length).to eq(0)
    expect(riley.felicidad).to eq(750)
  end

  it 'deberia sumar felicidad' do
    riley.procesos_mentales.push Restauracion_Cognitiva.new
    expect(riley.felicidad).to eq(1000)
    riley.descansar
    expect(riley.felicidad).to eq(1000)
    riley.felicidad -= 200
    riley.descansar
    expect(riley.felicidad).to eq(900)
  end

  it 'deberia borrar eventos_del_dia' do
    riley.procesos_mentales.push Liberar_Eventos_Del_Dia.new
    riley.eventos_del_dia.push evento_1
    riley.descansar
    expect(riley.eventos_del_dia.length).to eq(0)
  end

  it 'deberia rememorar un recuerdo' do
    riley.vivir evento_1
    riley.procesos_mentales.push Asentamiento.new
    riley.procesos_mentales.push Liberar_Eventos_Del_Dia.new
    riley.descansar
    expect(riley.eventos_del_dia.length).to eq(0)
    riley.rememorar
    expect(riley.eventos_del_dia.length).to eq(1)
  end

  it 'deberia negar recuerdo' do
    riley.vivir evento_1
    emocion_compuesta.emociones.push Tristeza.instance
    riley.emocion = emocion_compuesta
    expect(riley.emocion.niega? evento_1).to eq(true)
  end

  it 'deberia ser alegre' do
    emocion_compuesta.emociones.push Tristeza.instance
    emocion_compuesta.emociones.push Furia.instance
    emocion_compuesta.emociones.push Alegria.instance
    riley.emocion = emocion_compuesta
    expect(riley.emocion.es_alegre?).to eq(true)
  end

  it 'deberia aplicar logica de asentar recuerdos' do
    emocion_compuesta.emociones.push Tristeza.instance
    emocion_compuesta.emociones.push Alegria.instance
    riley.emocion = emocion_compuesta
    riley.vivir evento_1
    riley.procesos_mentales.push Asentamiento.new
    riley.descansar
    expect(riley.felicidad).to eq(900)
    expect(riley.pensamientos_centrales.length).to eq(2)
  end

  it 'deberia tener recuerdos repetidos' do
    riley.emocion = Terror.instance
    riley.vivir evento_1
    riley.vivir evento_2
    riley.vivir evento_1
    riley.procesos_mentales.push Profundizacion.new
    riley.descansar
    expect(riley.evento_repetido? evento_1).to eq(true)
  end

  it 'deberia tener un deja vu' do
    riley.emocion = Terror.instance
    riley.vivir evento_1
    riley.vivir evento_2
    riley.procesos_mentales.push Profundizacion.new
    riley.procesos_mentales.push Liberar_Eventos_Del_Dia.new
    riley.descansar
    expect(riley.eventos_del_dia.length).to eq(0)
    riley.vivir evento_1
    expect(riley.deja_vu?).to eq(true)
  end
end