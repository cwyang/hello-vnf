set(SCRIPTS_TO_COPY
  helloctl
  hello
)

foreach(SCRIPT ${SCRIPTS_TO_COPY})
    add_custom_command(
        OUTPUT "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${SCRIPT}"
        COMMAND ${CMAKE_COMMAND} -E copy
                "${CMAKE_CURRENT_SOURCE_DIR}/${SCRIPT}"
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${SCRIPT}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${SCRIPT}"
        BYPRODUCTS "${CMAKE_CURRENT_OUTPUT_DIR}/${SCRIPT}"
        COMMENT "Copying ${SCRIPT} to the asset directory"
    )

    # Add the custom command as a target
    add_custom_target(copy_${SCRIPT} ALL DEPENDS "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${SCRIPT}")
endforeach()
