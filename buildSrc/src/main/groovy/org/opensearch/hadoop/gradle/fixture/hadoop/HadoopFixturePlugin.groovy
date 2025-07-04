/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * The OpenSearch Contributors require contributions made to
 * this file be licensed under the Apache-2.0 license or a
 *
 * Modifications Copyright OpenSearch Contributors. See
 * GitHub history for details.
 */
 
/*
 * Licensed to Elasticsearch under one or more contributor
 * license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright
 * ownership. Elasticsearch licenses this file to you under
 * the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.opensearch.hadoop.gradle.fixture.hadoop

import org.opensearch.hadoop.gradle.fixture.hadoop.conf.HadoopClusterConfiguration
import org.gradle.api.NamedDomainObjectContainer
import org.gradle.api.NamedDomainObjectFactory
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.artifacts.dsl.RepositoryHandler
import org.gradle.api.artifacts.repositories.IvyArtifactRepository
import org.gradle.api.artifacts.repositories.IvyPatternRepositoryLayout

class HadoopFixturePlugin implements Plugin<Project> {

    private static final String APACHE_MIRROR = "https://archive.apache.org/dist/"

    static class HadoopFixturePluginExtension {
        private NamedDomainObjectContainer<HadoopClusterConfiguration> clusters

        HadoopFixturePluginExtension(final Project project) {
            this.clusters = project.container(HadoopClusterConfiguration.class, new NamedDomainObjectFactory<HadoopClusterConfiguration>() {
                @Override
                HadoopClusterConfiguration create(String name) {
                    return new HadoopClusterConfiguration(project, name)
                }
            })
        }

        HadoopClusterConfiguration cluster(String name, Closure config) {
            clusters.maybeCreate(name)
            return clusters.getByName(name, config)
        }

        NamedDomainObjectContainer<HadoopClusterConfiguration> getClusters() {
            return clusters
        }
    }

    @Override
    void apply(Project project) {
        HadoopFixturePluginExtension extension = project.getExtensions().create("hadoop", HadoopFixturePluginExtension.class, project)
        configureApacheMirrorRepository(project)
        project.afterEvaluate {
            extension.getClusters().forEach { config ->
                // Finish cluster setup
                HadoopClusterFormationTasks.setup(project, config)
            }
        }
    }

    private static configureApacheMirrorRepository(Project project) {
        RepositoryHandler repositoryHandler = project.getRepositories()
        repositoryHandler.add(repositoryHandler.ivy({IvyArtifactRepository ivyArtifactRepository ->
            ivyArtifactRepository.setUrl(APACHE_MIRROR)
            ivyArtifactRepository.patternLayout({IvyPatternRepositoryLayout ivyPatternRepositoryLayout ->
                ivyPatternRepositoryLayout.artifact("[module]/common/[module]-[revision]/[module]-[revision].[ext]")
                ivyPatternRepositoryLayout.artifact("[module]/[module]-[revision]/apache-[module]-[revision]-bin.[ext]")
                ivyPatternRepositoryLayout.artifact("spark/spark-[revision]/spark-[revision]-bin-hadoop3.[ext]")
                ivyPatternRepositoryLayout.setM2compatible(true)
            })
            ivyArtifactRepository.metadataSources({IvyArtifactRepository.MetadataSources metadataSources ->
                metadataSources.artifact()
            })
        }))
    }
}