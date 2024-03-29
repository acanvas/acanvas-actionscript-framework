/*
 * Copyright 2007-2012 the original author or authors.
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
package org.springextensions.actionscript.context.config.impl {
	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.context.config.IConfigurationPackage;
	import org.springextensions.actionscript.ioc.factory.process.impl.factory.ClassScannerObjectFactoryPostProcessor;

	/**
	 * @author Roland Zwaga
	 */
	public class FullConfigurationPackage implements IConfigurationPackage {

		/**
		 * Creates a new <code>FullConfigurationPackage</code> instance.
		 */
		public function FullConfigurationPackage() {
			super();
		}

		/**
		 * @param applicationContext The specified <code>IApplicationContext</code> that will be configured by the current <code>FullConfigurationPackage</code>.
		 */
		public function execute(applicationContext:IApplicationContext):void {
			applicationContext.addObjectFactoryPostProcessor(new ClassScannerObjectFactoryPostProcessor());
		}
	}
}