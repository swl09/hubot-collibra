chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'collibra', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/collibra')(@robot)

  it 'registers a hear listener', ->
    expect(@robot.hear).to.have.been.calledWith(/^collibra:\s*([^\n]+)/i)
