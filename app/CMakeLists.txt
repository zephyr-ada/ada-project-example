cmake_minimum_required(VERSION 3.15)

include(CMakeAda)

# Application project
# ===================

target_sources(
    app 
    PRIVATE
        src/main.cpp
)

add_ada_library(ada_app app/app.gpr lib)

zephyr_link_libraries(ada_app)
