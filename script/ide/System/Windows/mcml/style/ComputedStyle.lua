--[[
Title: style manager
Author(s): LiPeng
Date: 2018/1/16
Desc: singleton class for managing all file based styles globally. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/style/ComputedStyle.lua");
local ComputedStyle = commonlib.gettable("System.Windows.mcml.style.ComputedStyle");
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
NPL.load("(gl)script/ide/math/bit.lua");
NPL.load("(gl)script/ide/System/Windows/mcml/css/CSSStyleDeclaration.lua");
NPL.load("(gl)script/ide/System/Windows/mcml/platform/graphics/Length.lua");
local Length = commonlib.gettable("System.Windows.mcml.platform.graphics.Length");
local CSSStyleDeclaration = commonlib.gettable("System.Windows.mcml.css.CSSStyleDeclaration");

local ComputedStyle = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Windows.mcml.style.ComputedStyle"));
ComputedStyle:Property("Name", "ComputedStyle");


ComputedStyle:Signal("Changed");
--ComputedStyle:Signal("PositionChanged");

function ComputedStyle:ctor()
	self.test_name = "ComputedStyle";
	-- the result merged the styles from "id", "class" and inline style (the atrr "style")
	self.properties = nil;
--	-- the inline style (the atrr "style") of the page_element
--	self.inlineStyleDecl = nil;
	-- whether the css selector changed, such as the pageElement attr "id" or "class".
	self.beClassChanged = false;
	-- record the inline style change
	self.changes = {};

	self.box = {
		width = nil,
		height = nil,

		min_width = nil,
		min_height = nil,

		max_width = nil,
		max_height = nil,
	}
	--[[
	Webkit �� renderstyle�����Լ���

	// non-inherited attributes
    DataRef<StyleBoxData> m_box;
    DataRef<StyleVisualData> visual;
    DataRef<StyleBackgroundData> m_background;
    DataRef<StyleSurroundData> surround;
    DataRef<StyleRareNonInheritedData> rareNonInheritedData;

    // inherited attributes
    DataRef<StyleRareInheritedData> rareInheritedData;
    DataRef<StyleInheritedData> inherited;

    // list of associated pseudo styles
    OwnPtr<PseudoStyleCache> m_cachedPseudoStyles;
	]]
end

function ComputedStyle:init(style_decl)
--	style_decl["computed_style"] = self;
--
--	local proxy = {}
--	proxy[index] = style_decl
--	setmetatable(proxy, mt)

	self.properties = style_decl;

	--self:initBox();

	--self:emitChanged();
	self.beClassChanged = true;
	return self;
end

function ComputedStyle:GetStyle()
	return self.properties;
end

function ComputedStyle:GetOriginValue(key)
	return;
end

function ComputedStyle:ChangeValue(key, value)
	if(value == nil) then
		value = self:GetOriginValue(key);
	end
	self.changes[key] = self.changes[key] or {};
	self.changes[key]["old"] = self.changes[key]["old"] or self.properties[key];
	self.changes[key]["new"] = value;
	self.properties[key] = value;
	self:emitChanged();
end

function ComputedStyle:emitChanged()
	self:Changed()
end

function ComputedStyle:BeChanged()
	if(next(self.changes) or self.beClassChanged) then
		return true;
	end
	return false;
end

function ComputedStyle:Diff()
	return self:GetStyle():Diff(self.changes);
end

-- this is called after refreshed the pageElement according the changes table;
function ComputedStyle:ClearChanges()
	self.beClassChanged = false;
	if(next(self.changes)) then
		table.clear(self.changes);
	end
end

--function ComputedStyle:ChangeType()
--	local chagne_type = "ApplyCSS";
--	local key, _ = next(self.changes);
--	while(key) do
--		if(CSSStyleDeclaration.isResetField(key)) then
--			chagne_type = "Layout";
--		end
--	end
--	return chagne_type;
--end

function ComputedStyle:initBox()
	local properties = self.properties;
	self.box.width = properties["width"];
	self.box.height = properties["height"];

	self.box.min_width = properties["min-width"];
	self.box.min_height = properties["min-height"];

	self.box.max_width = properties["max-width"];
	self.box.max_height = properties["max-height"];
end

function ComputedStyle:InheritFrom(style)
	
end

function ComputedStyle:IsFloating() 
	return self:Floating() ~= "NoFloat";
end

function ComputedStyle:HasMargin()
	return true;
end

function ComputedStyle:HasBorder()
	return true;
end

function ComputedStyle:HasPadding()
	return true;
end

function ComputedStyle:HasOffset()
	return true;
end

-- margin-left
function ComputedStyle:MarginLeft()
	return self.properties:margin_left();
end

-- margin-top
function ComputedStyle:MarginTop()
	return self.properties:margin_top();
end

-- margin-right
function ComputedStyle:MarginRight()
	return self.properties:margin_right();
end

-- margin-bottom
function ComputedStyle:MarginBottom()
	return self.properties:margin_bottom();
end

-- margins
function ComputedStyle:Margins()
	return self:MarginLeft(), self:MarginTop(), self:MarginRight(), self:MarginBottom();
end

function ComputedStyle:MarginBefore()
	local write_mode = self:WritingMode();
	if(write_mode ==  "TopToBottomWritingMode") then
		return self:MarginTop();
	elseif(write_mode ==  "BottomToTopWritingMode") then
		return self:MarginBottom();
	elseif(write_mode ==  "LeftToRightWritingMode") then
		return self:MarginLeft();
	elseif(write_mode ==  "RightToLeftWritingMode") then
		return self:MarginRight();
	end
	return self:MarginTop();
end

function ComputedStyle:MarginAfter()
	local write_mode = self:WritingMode();
	if(write_mode ==  "TopToBottomWritingMode") then
		return self:MarginBottom();
	elseif(write_mode ==  "BottomToTopWritingMode") then
		return self:MarginTop();
	elseif(write_mode ==  "LeftToRightWritingMode") then
		return self:MarginRight();
	elseif(write_mode ==  "RightToLeftWritingMode") then
		return self:MarginLeft();
	end
	return self:MarginBottom();
end

function ComputedStyle:MarginStart()
	local start_;
	if(self:IsHorizontalWritingMode()) then
		start_ = if_else(self:IsLeftToRightDirection(), self:MarginLeft(), self:MarginRight());
	else
		start_ = if_else(self:IsLeftToRightDirection(), self:MarginTop(), self:MarginBottom());
	end
	return start_;
end

function ComputedStyle:MarginEnd()
	local end_;
	if(self:IsHorizontalWritingMode()) then
		end_ = if_else(self:IsLeftToRightDirection(), self:MarginRight(), self:MarginLeft());
	else
		end_ = if_else(self:IsLeftToRightDirection(), self:MarginBottom(), self:MarginTop());
	end
	return end_;
end

function ComputedStyle:MarginBeforeUsing(otherStyle)
	local write_mode = otherStyle:WritingMode();
	if(write_mode ==  "TopToBottomWritingMode") then
		return self:MarginTop();
	elseif(write_mode ==  "BottomToTopWritingMode") then
		return self:MarginBottom();
	elseif(write_mode ==  "LeftToRightWritingMode") then
		return self:MarginLeft();
	elseif(write_mode ==  "RightToLeftWritingMode") then
		return self:MarginRight();
	end
	return self:MarginTop();
end

function ComputedStyle:MarginAfterUsing(otherStyle)
	local write_mode = otherStyle:WritingMode();
	if(write_mode ==  "TopToBottomWritingMode") then
		return self:MarginBottom();
	elseif(write_mode ==  "BottomToTopWritingMode") then
		return self:MarginTop();
	elseif(write_mode ==  "LeftToRightWritingMode") then
		return self:MarginRight();
	elseif(write_mode ==  "RightToLeftWritingMode") then
		return self:MarginLeft();
	end
	return self:MarginBottom();
end

function ComputedStyle:MarginStartUsing(otherStyle)
	local start_;
	if(otherStyle:IsHorizontalWritingMode()) then
		start_ = if_else(otherStyle:IsLeftToRightDirection(), self:MarginLeft(), self:MarginRight());
	else
		start_ = if_else(otherStyle:IsLeftToRightDirection(), self:MarginTop(), self:MarginBottom());
	end
	return start_;
end

function ComputedStyle:MarginEndUsing(otherStyle)
	local end_;
	if(otherStyle:IsHorizontalWritingMode()) then
		end_ = if_else(otherStyle:IsLeftToRightDirection(), self:MarginRight(), self:MarginLeft());
	else
		end_ = if_else(otherStyle:IsLeftToRightDirection(), self:MarginBottom(), self:MarginTop());
	end
	return end_;
end

-- borders
function ComputedStyle:Border()
	return;
end

-- border-left
function ComputedStyle:BorderLeft()
	--return self.properties:border_left();
end

-- border-top
function ComputedStyle:BorderTop()
	--return self.properties:border_top();
end

-- border-right
function ComputedStyle:BorderRight()
	--return self.properties:border_right();
end

-- border-bottom
function ComputedStyle:BorderBottom()
	--return self.properties:border_bottom();
end

function ComputedStyle:BorderBefore()
	return self:BorderTop();
end

function ComputedStyle:BorderAfter()
	return self:BorderBottom();
end

function ComputedStyle:BorderStart()
	return self:BorderLeft();
end

function ComputedStyle:BorderEnd()
	return self:BorderRight();
end

function ComputedStyle:BorderTopLeftRadius() 
	--return surround->border.topLeft();
end

function ComputedStyle:BorderTopRightRadius() 
	--return surround->border.topRight();
end

function ComputedStyle:BorderBottomLeftRadius()
	--return surround->border.bottomLeft(); 
end
function ComputedStyle:BorderBottomRightRadius()
	--return surround->border.bottomRight(); 
end
function ComputedStyle:HasBorderRadius() 
	--return surround->border.hasBorderRadius(); 
end

function ComputedStyle:BorderLeftWidth()
	return self.properties:border_left_width();
end

function ComputedStyle:BorderLeftStyle()
	return self.properties:border_left_style();
end

function ComputedStyle:BorderLeftIsTransparent() 
	return false;
end

function ComputedStyle:BorderRightWidth()
	return self.properties:border_right_width();
end

function ComputedStyle:BorderRightStyle()
	return self.properties:border_right_style();
end

function ComputedStyle:BorderRightIsTransparent() 
	return false;
end

function ComputedStyle:BorderTopWidth() 
	return self.properties:border_top_width();
end

function ComputedStyle:BorderTopStyle()
	return self.properties:border_top_style();
end

function ComputedStyle:BorderTopIsTransparent() 
	return false;
end

function ComputedStyle:BorderBottomWidth()
	return self.properties:border_bottom_width();
end

function ComputedStyle:BorderBottomStyle()
	return self.properties:border_bottom_style();
end

function ComputedStyle:BorderBottomIsTransparent()
	return false;
end

function ComputedStyle:BorderBeforeWidth()
	return self:BorderTopWidth();
end

function ComputedStyle:BorderAfterWidth()
	return self:BorderBottomWidth();
end

function ComputedStyle:BorderStartWidth()
	return self:BorderLeftWidth();
end

function ComputedStyle:BorderEndWidth()
	return self:BorderRightWidth();
end

-- padding-left
function ComputedStyle:PaddingLeft()
	return self.properties:padding_left();
end

-- padding-top
function ComputedStyle:PaddingTop()
	return self.properties:padding_top();
end

-- padding-right
function ComputedStyle:PaddingRight()
	return self.properties:padding_right();
end

-- padding-bottom
function ComputedStyle:PaddingBottom()
	return self.properties:padding_bottom();
end

-- paddings
function ComputedStyle:Paddings()
	return self:PaddingLeft(), self:PaddingTop(), self:PaddingRight(), self:PaddingBottom();
end

function ComputedStyle:PaddingBox()

end

function ComputedStyle:PaddingBefore()
	return self:PaddingTop();
end

function ComputedStyle:PaddingAfter()
	return self:PaddingBottom();
end

function ComputedStyle:PaddingStart()
	return self:PaddingLeft();
end

function ComputedStyle:PaddingEnd()
	return self:PaddingRight();
end

-- width
function ComputedStyle:Width()
	return self.properties:Width();
end

-- min-width
function ComputedStyle:MinWidth()
	return self.properties:MinWidth() or 0;
end

-- max-width
function ComputedStyle:MaxWidth()
	return self.properties:MaxWidth();
end

-- height
function ComputedStyle:Height()
	return self.properties:Height();
end

-- min-height
function ComputedStyle:MinHeight()
	return self.properties:MinHeight() or 0;
end

-- max-height
function ComputedStyle:MaxHeight()
	return self.properties:MaxHeight();
end

function ComputedStyle:LogicalWidth()
	if(self:IsHorizontalWritingMode()) then
		return self:Width();
	end
	return self:Height();
end

function ComputedStyle:LogicalHeight()
	if(self:IsHorizontalWritingMode()) then
		return self:Height();
	end
	return self:Width();
end

function ComputedStyle:LogicalMinWidth()
	if(self:IsHorizontalWritingMode()) then
		return self:MinWidth();
	end
	return self:MinHeight();
end

function ComputedStyle:LogicalMaxWidth()
	if(self:IsHorizontalWritingMode()) then
		return self:MaxWidth();
	end
	return self:MaxHeight();
end

function ComputedStyle:LogicalMinHeight()
	if(self:IsHorizontalWritingMode()) then
		return self:MinHeight();
	end
	return self:MinWidth();
end

function ComputedStyle:LogicalMaxHeight()
	if(self:IsHorizontalWritingMode()) then
		return self:MaxHeight();
	end
	return self:MaxWidth();
end

-- left
function ComputedStyle:Left()
	return self.properties:Left();
end

-- top
function ComputedStyle:Top()
	return self.properties:Top();
end

-- right
function ComputedStyle:Right()
	return self.properties:Right();
end

-- bottom
function ComputedStyle:Bottom()
	return self.properties:Bottom();
end

-- Accessors for positioned object edges that take into account writing mode.
function ComputedStyle:LogicalLeft()
	return if_else(self:IsHorizontalWritingMode(),self:Left(),self:Top());
end

function ComputedStyle:LogicalRight()
	return if_else(self:IsHorizontalWritingMode(),self:Right(),self:Bottom());
end

function ComputedStyle:LogicalTop()
	return if_else(self:IsHorizontalWritingMode(), self:Top(), self:Bottom());
	--return if_else(self:IsHorizontalWritingMode() ? (isFlippedBlocksWritingMode() ? bottom() : top()) : (isFlippedBlocksWritingMode() ? right() : left());
end

function ComputedStyle:LogicalBottom()
	return if_else(self:IsHorizontalWritingMode(), self:Bottom(), self:Top());
	--return isHorizontalWritingMode() ? (isFlippedBlocksWritingMode() ? top() : bottom()) : (isFlippedBlocksWritingMode() ? left() : right());
end

--enum EPosition {
--    StaticPosition, RelativePosition, AbsolutePosition, FixedPosition
--};
local position_map = {
	["static"] = "StaticPosition",
	["relative"] = "RelativePosition",
	["absolute"] = "AbsolutePosition",
	["fixed"] = "FixedPosition",
};

-- position
function ComputedStyle:Position()
	local position = self.properties:Position();
	return position_map[position];
end

local display_map = {
	["inline"] = "INLINE",
	["block"] = "BLOCK",
	["list-item"] = "LIST_ITEM",
	["run-in"] = "RUN_IN",
	["compact"] = "COMPACT",
	["inline-block"] = "INLINE_BLOCK",
	["table"] = "TABLE",
	["inline-table"] = "INLINE_TABLE",
	["table-row-group"] = "TABLE_ROW_GROUP",
	["table-header-group"] = "TABLE_FOOTER_GROUP",
	["table-footer-group"] = "TABLE_FOOTER_GROUP",
	["table-row"] = "TABLE_ROW",
	["table-column-group"] = "TABLE_COLUMN_GROUP",
	["table-column"] = "TABLE_COLUMN",
	["table-cell"] = "TABLE_CELL",
	["table-caption"] = "TABLE_CAPTION",
	["box"] = "BOX",
	["inline-box"] = "INLINE_BOX",
	["flexbox"] = "FLEXBOX",
	["inline-flexbox"] = "INLINE_FLEXBOX",
	["none"] = "NONE"
};

-- display
function ComputedStyle:Display()
	local display = self.properties:Display();
	return display_map[display];
end

function ComputedStyle:OriginalDisplay()
	return "INLINE";
end

function ComputedStyle:IsDisplayReplacedType()
	local display = self:Display();
    return display == "INLINE_BLOCK" or display == "INLINE_BOX" or display == "INLINE_TABLE";
end

function ComputedStyle:IsDisplayInlineType()
    return self:Display() == "INLINE" or self:IsDisplayReplacedType();
end

function ComputedStyle:IsOriginalDisplayInlineType()
	local originalDisplay = self:OriginalDisplay();
	return originalDisplay == "INLINE" or originalDisplay == "INLINE_BLOCK"
            or originalDisplay == "INLINE_BOX" or originalDisplay == "INLINE_TABLE";
end

--enum EFloat {
--    NoFloat, LeftFloat, RightFloat, PositionedFloat
--};

local float_map = {
	["none"] = "NoFloat",
	["left"] = "LeftFloat",
	["right"] = "RightFloat",
};

-- float
function ComputedStyle:Floating()
	local float = self.properties:Floating();
	return float_map[float];
end

-- algin
function ComputedStyle:Align()
	return self.properties:Align();
end

-- valign
function ComputedStyle:Valign()
	return self.properties:Valign();
end


-----------------------------------------------------------------------------------------------------
----------------	webkit/chromium	function

function ComputedStyle:IsHorizontalWritingMode()
	--return true;
	local mode = self:WritingMode();
	return mode == "TopToBottomWritingMode" or mode == "BottomToTopWritingMode";
end

function ComputedStyle:IsFlippedLinesWritingMode()
	local mode = self:WritingMode();
	return mode == "LeftToRightWritingMode" or mode == "BottomToTopWritingMode";
end

function ComputedStyle:IsFlippedBlocksWritingMode()
	local mode = self:WritingMode();
	return mode == "RightToLeftWritingMode" or mode == "BottomToTopWritingMode";
end

function ComputedStyle:WritingMode()
	return "TopToBottomWritingMode";	
end

function ComputedStyle:OverflowX()
	return self.properties:OverflowX();
end

function ComputedStyle:OverflowY()
	return self.properties:OverflowY();
end
-- enum EVisibility { VISIBLE, HIDDEN, COLLAPSE };
function ComputedStyle:Visibility()
	--return self.properties:Visibility();
	return "VISIBLE";
end
-- TextDirection, value can be "LTR", "RTL";
function ComputedStyle:Direction() 
	return self.properties:TextDirection();
end

function ComputedStyle:IsLeftToRightDirection()
	return self:Direction() == "LTR";
end

function ComputedStyle:AutoWrap(ws)
	ws = ws or self:WhiteSpace();
	return ws ~= "NOWRAP" and ws ~= "PRE";
end
-- return value can be:"UBNormal","Embed","Override","Isolate","Plaintext"
function ComputedStyle:UnicodeBidi()
	return "UBNormal";
end

function ComputedStyle:PreserveNewline(ws)
	ws = ws or self:WhiteSpace();
	return ws ~= "NORMAL" and ws ~= "NOWRAP";
end

local white_space_map = {
	["normal"] = "NORMAL", 
	["pre"] = "PRE", 
	["pre-wrap"] = "PRE_WRAP", 
	["pre-line"] = "PRE_LINE", 
	["nowrap"] = "NOWRAP", 
	["khtml-nowrap"] = "KHTML_NOWRAP"
}

function ComputedStyle:WhiteSpace()
	return "NORMAL";
end

function ComputedStyle:BoxSizing()
	return "CONTENT_BOX"
end
-- property "text-overflow"
function ComputedStyle:TextOverflow()
	return "clip";
end

--// Static pseudo styles. Dynamic ones are produced on the fly.
--enum PseudoId {
--    // The order must be NOP ID, public IDs, and then internal IDs.
--    NOPSEUDO, FIRST_LINE, FIRST_LETTER, BEFORE, AFTER, SELECTION, FIRST_LINE_INHERITED, SCROLLBAR,
--    // Internal IDs follow:
--    SCROLLBAR_THUMB, SCROLLBAR_BUTTON, SCROLLBAR_TRACK, SCROLLBAR_TRACK_PIECE, SCROLLBAR_CORNER, RESIZER,
--    INPUT_LIST_BUTTON,
--    AFTER_LAST_INTERNAL_PSEUDOID,
--    FULL_SCREEN, FULL_SCREEN_DOCUMENT, FULL_SCREEN_ANCESTOR, ANIMATING_FULL_SCREEN_TRANSITION,
--    FIRST_PUBLIC_PSEUDOID = FIRST_LINE,
--    FIRST_INTERNAL_PSEUDOID = SCROLLBAR_THUMB,
--    PUBLIC_PSEUDOID_MASK = ((1 << FIRST_INTERNAL_PSEUDOID) - 1) & ~((1 << FIRST_PUBLIC_PSEUDOID) - 1)
--};
function ComputedStyle:StyleType()
	return "NOPSEUDO";
end

function ComputedStyle:SpecifiesColumns()
	return false;
end

function ComputedStyle:ColumnSpan()
	return false;
end

-- return: "HORIZONTAL", "VERTICAL"
function ComputedStyle:BoxOrient()
	return "HORIZONTAL";
end

--return: "BSTRETCH", "BSTART", "BCENTER", "BEND", "BJUSTIFY", "BBASELINE"
function ComputedStyle:BoxAlign()
	return "BSTRETCH";
end
--TAAUTO, LEFT, RIGHT, CENTER, JUSTIFY, WEBKIT_LEFT, WEBKIT_RIGHT, WEBKIT_CENTER, TASTART, TAEND
function ComputedStyle:TextAlign()
	return "TAAUTO";
end
-- return: "MCOLLAPSE", "MSEPARATE", "MDISCARD"
function ComputedStyle:MarginBeforeCollapse()
	return "MCOLLAPSE";
end
-- return: "MCOLLAPSE", "MSEPARATE", "MDISCARD"
function ComputedStyle:MarginAfterCollapse()
	return "MCOLLAPSE";
end

function ComputedStyle:HasAutoColumnCount()
	return true;
end

function ComputedStyle:HasAutoColumnWidth()
	return true;
end

function ComputedStyle:IsDisplayReplacedType()
	local display = self:Display();
    return display == "INLINE_BLOCK" or display == "INLINE_BOX" or display == "INLINE_TABLE";
end

function ComputedStyle:IsDisplayInlineType()
    return self:Display() == "INLINE" or self:IsDisplayReplacedType();
end

function ComputedStyle:FontSize()
	return self.properties:FontSize();
end

function ComputedStyle:CollapseWhiteSpace(ws)
    -- Pre and prewrap do not collapse whitespace.
	ws = ws or self:WhiteSpace();
    return ws ~= "PRE" and ws ~= "PRE_WRAP";
end

--bool isCollapsibleWhiteSpace(UChar c) const
function ComputedStyle:IsCollapsibleWhiteSpace(c)
	if(c == " " or c == "\t") then
		return self:CollapseWhiteSpace();
	elseif(c == "\n") then
		return not self:PreserveNewline();
	end
--    switch (c) {
--        case ' ':
--        case '\t':
--            return collapseWhiteSpace();
--        case '\n':
--            return !preserveNewline();
--    }
    return false;
end

-- return: "NBNORMAL", "SPACE"
function ComputedStyle:NbspMode()
	return "NBNORMAL";
end

function ComputedStyle:TextIndent()
	return 0;
end

function ComputedStyle:Locale()
	return nil;
end
-- return value: "NormalWordBreak", "BreakAllWordBreak", "BreakWordBreak"
function ComputedStyle:WordBreak()
	return "NormalWordBreak";
end
-- return value: "NormalWordWrap", "BreakWordWrap"
function ComputedStyle:WordWrap()
	return "NormalWordWrap";
end

function ComputedStyle:BreakWords()
	return self:WordBreak() == "BreakWordBreak" or self:WordWrap() == "BreakWordWrap";
end

function ComputedStyle:Font()
	return self.properties:GetFontSettings();
end

function ComputedStyle:WordSpacing()
	if(not self.wordSpacing) then
--		local font = self:Font();
--		self.wordSpacing = _guihelper.GetTextWidth(" ", font);	
		self.wordSpacing = 0;
	end
	return self.wordSpacing;
end
-- return value: "LBNORMAL", "AFTER_WHITE_SPACE"
function ComputedStyle:KhtmlLineBreak()
	return "LBNORMAL"
end

function ComputedStyle:BreakOnlyAfterWhiteSpace()
    return self:WhiteSpace() == "PRE_WRAP" or self:KhtmlLineBreak() == "AFTER_WHITE_SPACE";
end
-- return value: "LogicalOrder", "VisualOrder"
function ComputedStyle:RtlOrdering()
	return "LogicalOrder"
end

ComputedStyle.LineBoxContainFlags = { 
	["LineBoxContainNone"] = 0x0, 
	["LineBoxContainBlock"] = 0x1, 
	["LineBoxContainInline"] = 0x2, 
	["LineBoxContainFont"] = 0x4, 
	["LineBoxContainGlyphs"] = 0x8,
    ["LineBoxContainReplaced"] = 0x10, 
	["LineBoxContainInlineBox"] = 0x20 
};

function ComputedStyle:LineBoxContain()
	local contain = mathlib.bit.bor(ComputedStyle.LineBoxContainFlags.LineBoxContainBlock, ComputedStyle.LineBoxContainFlags.LineBoxContainInline);
	return 	mathlib.bit.bor(contain, ComputedStyle.LineBoxContainFlags.LineBoxContainReplaced);
end

function ComputedStyle:FontHeight()
	local _, font_size = self:Font();
	return font_size;
end

function ComputedStyle:FontAscent(baselineType)
	baselineType = baselineType or "AlphabeticBaseline"
	return self:FontHeight() - self:FontHeight() / 2;
end

function ComputedStyle:FontDescent(baselineType)
	baselineType = baselineType or "AlphabeticBaseline"
	return self:FontHeight() / 2;
end

-- if not set line-height, we use font-size * 120%;
function ComputedStyle:LineHeight()
--	local line_height = self.properties:LineHeight();
--	return "";
	return self:FontHeight() + 4;
end

function ComputedStyle:ComputedLineHeight()
--	Length lh = lineHeight();
--
--    // Negative value means the line height is not set.  Use the font's built-in spacing.
--    if (lh.isNegative())
--        return fontMetrics().lineSpacing();
--
--    if (lh.isPercent())
--        return lh.calcMinValue(fontSize());
--
--    return lh.value();
	return self:LineHeight();
end

--enum EVerticalAlign {
--    BASELINE, MIDDLE, SUB, SUPER, TEXT_TOP,
--    TEXT_BOTTOM, TOP, BOTTOM, BASELINE_MIDDLE, LENGTH
--};
function ComputedStyle:VerticalAlign()
	return "BASELINE";
end

-- enum TextEmphasisMark { TextEmphasisMarkNone, TextEmphasisMarkAuto, TextEmphasisMarkDot, TextEmphasisMarkCircle, TextEmphasisMarkDoubleCircle, TextEmphasisMarkTriangle, TextEmphasisMarkSesame, TextEmphasisMarkCustom };
function ComputedStyle:TextEmphasisMark()
	return "TextEmphasisMarkNone"
end

function ComputedStyle:TextCombine()
	return "TextCombineNone"
end

function ComputedStyle:HasTextCombine()
	return self:TextCombine() ~= "TextCombineNone";
end

function ComputedStyle:Color()
	return self.properties:Color();
end

function ComputedStyle:Opacity()
	return 1.0;
end

function ComputedStyle:HasAutoZIndex()
	return true;
end
--enum EOverflow { OVISIBLE, OHIDDEN, OSCROLL, OAUTO, OOVERLAY, OMARQUEE };
function ComputedStyle:OverflowX()
	return "OVISIBLE";
end

function ComputedStyle:OverflowY()
	return "OVISIBLE";
end

-- CSS3 Marquee Properties
-- enum EMarqueeBehavior { MNONE, MSCROLL, MSLIDE, MALTERNATE };
function ComputedStyle:MarqueeBehavior()
	return "MSCROLL";
end
-- enum ControlPart:  have much value;
function ComputedStyle:Appearance()
	return "NoControlPart";
end

function ComputedStyle:HasAppearance() 
	return self:Appearance() ~= "NoControlPart";
end
-- enum EBorderFit { BorderFitBorder, BorderFitLines };
function ComputedStyle:BorderFit()
	return "BorderFitBorder";
end

function ComputedStyle:HasMask()
	return false;
end

function ComputedStyle:HasClip()
	return false;
end
--enum EClear {
--    CNONE = 0, CLEFT = 1, CRIGHT = 2, CBOTH = 3
--};
function ComputedStyle:Clear()
	return "CNONE";
end

-- Whether or not a positioned element requires normal flow x/y to be computed
-- to determine its position.
function ComputedStyle:HasAutoLeftAndRight()
	return Length.IsAuto(self:Left()) and Length.IsAuto(self:Right());
end

function ComputedStyle:HasAutoTopAndBottom()
	return Length.IsAuto(self:Top()) and Length.IsAuto(self:Bottom());
	--return top().isAuto() && bottom().isAuto();
end

function ComputedStyle:HasStaticInlinePosition(horizontal)
	return if_else(horizontal, self:HasAutoLeftAndRight(), self:HasAutoTopAndBottom());
end

function ComputedStyle:HasStaticBlockPosition(horizontal)
	return if_else(horizontal, self:HasAutoTopAndBottom(), self:HasAutoLeftAndRight());
end

function ComputedStyle:ZIndex()
	return 0;
end