/*
Copyright (c) 2003-2010, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
  config.PreserveSessionOnFileBrowser = true;
  config.forcePasteAsPlainText = true;
  // Define changes to default configuration here. For example:
  config.language = 'en';
  // config.uiColor = '#AADC6E';

  //config.ContextMenu = ['Generic','Anchor','Flash','Select','Textarea','Checkbox','Radio','TextField','HiddenField','ImageButton','Button','BulletedList','NumberedList','Table','Form'] ;

  config.forceSimpleAmpersand = true;
  
  config.height = '400px';
  config.width = '730px';
  
  //config.resize_enabled = false;
  //config.resize_maxHeight = 2000;
  //config.resize_maxWidth = 750;
  
  //config.startupFocus = true;
  
  // works only with en, ru, uk languages
  config.extraPlugins = "embed,attachment,tramlineslink";
  config.removePlugins = 'link';
  
  config.toolbar = 'Tramlines';
  
  config.toolbar_Easy =
    [
        ['Source','-','Preview','Templates'],
        ['Cut','Copy','Paste','PasteText','PasteFromWord'],
        ['Maximize','-','About'],
        ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
        ['Styles','Format'],
        ['Bold','Italic','Underline','Strike','-','Subscript','Superscript', 'TextColor'],
        ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
        ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
        ['Link','Unlink','Anchor'],
        ['Image','Embed','Flash','Attachment','Table','HorizontalRule','Smiley','SpecialChar','PageBreak']
    ];
  
  config.toolbar_Tramlines = [
    ['Source', '-', 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord'],
    ['Undo', 'Redo'],
    ['Styles'], '/',
    //['Bold', 'Italic', 'Underline', '-'],
    ['Bold', 'Italic', '-'],
    ['NumberedList', 'BulletedList'],
    ['Link', 'Unlink', 'Anchor'],
    ['Image', 'Table', 'SpecialChar']
  ];

  config.stylesCombo_stylesSet = 'tramlines';
  config.filebrowserWindowWidth = '600';
  config.filebrowserWindowHeight = '600';
  
};

CKEDITOR.on( 'dialogDefinition', function( ev )
	{
	  
	  
		// Take the dialog name and its definition from the event data.
		var dialogName = ev.data.name;
		var dialogDefinition = ev.data.definition;




		// Check if the definition is from the dialog we're
		// interested on (the Link dialog).
		if ( dialogName == 'link' )
		{
			// FCKConfig.LinkDlgHideAdvanced = true
			dialogDefinition.removeContents( 'advanced' );

			// FCKConfig.LinkDlgHideTarget = true
			// dialogDefinition.removeContents( 'target' );

			// Enable this part only if you don't remove the 'target' tab in the previous block.
 
			// FCKConfig.DefaultLinkTarget = '_blank'
			// Get a reference to the "Target" tab.
			var targetTab = dialogDefinition.getContents( 'target' );
			targetTab.remove('linkTargetName');
			targetTab.remove('popupFeatures');
			// Set the default value for the URL field.
			var targetField = targetTab.get( 'linkTargetType' );
			targetField[ 'default' ] = '_self';

		}
 
		if ( dialogName == 'image' )
		{
			
			// FCKConfig.ImageDlgHideAdvanced = true	
			dialogDefinition.removeContents( 'advanced' );
			// FCKConfig.ImageDlgHideLink = true
			dialogDefinition.removeContents( 'Link' );
			// FCKConfig.ImageDlgHideUpload = true
			dialogDefinition.removeContents( 'Upload' );
			// dialogDefinition.removeButton('btnResetSize');
			// dialogDefinition.removeButton('btnLockSizes');
			
			var urlTab = dialogDefinition.getContents( 'info' );
			tabTitle = urlTab.elements[0].children[0];
			tabTitle['html'] = '';
			
			var previewHtml = urlTab.elements[2].children[1].children[0];
			urlTab.elements[2].children[1]['id'] = 'oldPreviewHtml';
			previewHtml['html'] = previewHtml['html'].replace(/(<img.+\/><\/a>).*(<\/div><\/div>)/,'$1$2');
			
			sizeOptionLinks = urlTab.elements[2].children[0].children[0].children[1];
			sizeOptionLinks['hidden'] = true;
			
			var browseButton = urlTab.get('browse');
			browseButton['label'] = "Select your image";
			browseButton['style'] = 'float: left';
			
			var urlField = urlTab.get('txtUrl');
			urlField['hidden'] = true;
			urlField['width'] = '1px';
			
			urlTab.elements[0].children[0] = browseButton;
			urlTab.elements[0].children[1] = urlField;
			
			var widthField = urlTab.get('txtWidth');
			widthField['hidden'] = true;
			var heightField = urlTab.get('txtHeight');
			heightField['hidden'] = true;
			var borderField = urlTab.get('txtBorder');
			borderField['hidden'] = true;
			var hSpaceField = urlTab.get('txtHSpace');
			hSpaceField['hidden'] = true;
			var vSpaceField = urlTab.get('txtVSpace');
			vSpaceField['hidden'] = true;
			
			var textAltField = urlTab.get('txtAlt');
			textAltField['width'] = '200px';
			
			var alignField = urlTab.get('cmbAlign');
			alignField['default'] = 'left';
			urlTab.remove('cmbAlign');
			urlTab.add(alignField, 'txtAlt');			
			urlTab.remove('oldPreviewHtml');
			urlTab.add(previewHtml, 'txtWidth');
			
		}

	});
	
CKEDITOR.config.forceSimpleAmpersand = true;
