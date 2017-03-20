require 'rspec'
require_relative '../src/Intensamente'

describe 'My behaviour' do

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
    riley.procesos_mentales.push(asentamiento)
    expect(riley.largo_plazo.length).to eq(0)
    riley.descansar
    expect(riley.largo_plazo.length).to eq(3)
  end

  it 'deberia asentar todos menos uno' do
    riley.vivir evento_1
    riley.vivir evento_2
    riley.vivir evento_3
    riley.procesos_mentales.push(asentamiento_selectivo)
    expect(riley.largo_plazo.length).to eq(0)
    riley.descansar
    expect(riley.largo_plazo.length).to eq(2)
  end
end