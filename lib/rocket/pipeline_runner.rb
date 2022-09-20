# frozen_string_literal: true

module Rocket
  #
  # In charge to parse pipeline annotations, initializing and running pipeline steps.
  #
  class PipelineRunner
    # @return [Float] Time to wait in second before resuming all alive steps
    TICK = 0.1

    # @return [Array<PipelineStep>] All the steps declared in the pipeline
    attr_reader :steps
    # @return [Array<PipelineStep>] The remaining steps to run
    attr_reader :remaining_steps

    #
    # Parses and initializes the given pipeline's steps.
    #
    # @param [Pipeline] pipeline The pipeline to parse and run.
    #
    def initialize(pipeline)
      annotated_methods = pipeline.class.annotated_methods

      @steps = step_names(annotated_methods).map do |name|
        PipelineStep.new(pipeline, name)
      end

      annotated_methods.each do |method|
        step_by(name: method.name).left = method.find_annotation(:after).params.map do |left_step_name|
          step_by(name: left_step_name)
        end
      end

      @remaining_steps = @steps.dup
    end

    #
    # Actually runs the pipeline.
    # Resumes step's fiber until they are all finished.
    #
    # @return [void]
    #
    def run
      until @remaining_steps.empty?
        @remaining_steps.each do |step|
          next @remaining_steps.delete(step) unless step.alive?

          step.resume
        end

        sleep(TICK)
      end
    end

    #
    # Returns the current step based on fiber execution context.
    #
    # @return [PipelineStep] The currently running step.
    #
    def current_step
      step_by fiber: Fiber.current
    end

    #
    # Parses given annotated methods and extract all step names.
    #
    # @param [Array<Annotable::AnnotatedMethod>] annotated_methods The annotated method to parse
    #
    # @return [Array<Symbol>] The declared step's names
    #
    def step_names(annotated_methods)
      annotated_methods.flat_map do |method|
        [method.name, *method.find_annotation(:after).params]
      end.uniq
    end

    #
    # Finds a step corresponding to the given name and value.
    #
    # @example Finds a step named `my-step`
    #   step_by(name: :my_step)
    #
    # @param [Hash<Symbol: Object>] **name_and_val Step attribute's name and value
    #
    # @return [PipelineStep, Nil] Found step if any
    #
    def step_by(**name_and_val)
      name, value = *name_and_val.to_a.first

      steps.find do |step|
        step.send(name) == value
      end
    end
  end
end
