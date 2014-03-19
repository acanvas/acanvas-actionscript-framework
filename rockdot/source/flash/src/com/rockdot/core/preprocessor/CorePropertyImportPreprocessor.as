/*
* Copyright 2007-2010 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
 */
package com.rockdot.core.preprocessor {
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_objects;
	import org.springextensions.actionscript.ioc.config.impl.xml.preprocess.IXMLObjectDefinitionsPreprocessor;

	use namespace spring_actionscript_objects;

	/**
	 * XML Preprocessor for the "import" element that imports external properties files. These nodes are
	 * preprocessed to @see PropertyPlaceholderConfigurer objects.
	 * 
	 * @author Christophe Herreman
	 * @flowerModelElementId _0MVPMC9LEeG0Qay4mHgS6g
	 */
	public class CorePropertyImportPreprocessor implements IXMLObjectDefinitionsPreprocessor {

		private var _language : String;


		public function CorePropertyImportPreprocessor(language : String) {
			_language = language;
			super();
		}

		/**
		 * @inheritDoc
		 * Iterates over &lt;property&gt; nodes which are preprocessed to @see PropertyPlaceholderConfigurer objects.
		 */
		public function preprocess(xml:XML):XML {
			var propertyNodes:XMLList = xml.property;
			var filename : String = "";

			for each (var propertyNode:XML in propertyNodes) {
				if (propertyNode.attribute('file').length() > 0) {
					filename = propertyNode.attribute('file')[0];
					
					/* Replace language placeholder */
					if(_language && filename.indexOf("@@language@@")!=-1){
						filename = String(propertyNode.attribute('file')[0]).split("@@language@@").join(_language);
					}
					
					var node:XML = <property file={filename} />; 

					/* Add new node */
					xml.appendChild(node);
					
					/* Delete old node */
					delete xml.property[0];
				}

			}

			return xml;
		}
	}
}